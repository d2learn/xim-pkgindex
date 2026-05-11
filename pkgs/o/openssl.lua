package = {
    spec = "1",
    homepage = "https://www.openssl.org",
    name = "openssl",
    description = "TLS/SSL and cryptography toolkit",
    authors = {"The OpenSSL Project"},
    licenses = {"Apache-2.0"},
    repo = "https://github.com/openssl/openssl",

    type = "package",
    archs = { "x86_64" },
    status = "stable",
    categories = { "crypto", "tls", "ssl", "library" },
    keywords = { "openssl", "libssl", "libcrypto", "tls", "ssl", "https" },

    programs = {
        "openssl", "c_rehash"
    },

    xvm_enable = true,

    xpm = {
        linux = {
            deps = { "xim:glibc@2.39" },
            ["latest"] = { ref = "3.1.5" },
            ["3.1.5"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")
-- elfpatch import removed: predicate-driven auto-patch (post 2026-05-02
-- design) reads glibc.lua's exports.runtime.loader and rewrites our
-- INTERP / RPATH automatically. No install-hook elfpatch call needed.

local libs = {
    "libcrypto.so", "libcrypto.so.3", "libcrypto.a",
    "libssl.so",    "libssl.so.3",    "libssl.a"
}

-- list files matching a glob pattern (standard Lua, replaces xmake os.files)
local function list_files(pattern)
    local result = {}
    local f = io.popen('ls -d ' .. pattern .. ' 2>/dev/null')
    if f then
        for line in f:lines() do
            local clean = line:gsub("[\r\n]+$", "")
            if clean ~= "" and os.isfile(clean) then
                table.insert(result, clean)
            end
        end
        f:close()
    end
    return result
end

local xpkg_binding_tree = package.name .. "-binding-tree"

local function get_sys_usr_includedir()
    return path.join(system.subos_sysrootdir(), "usr/include")
end

function install()
    local openssl_dir = pkginfo.install_file()
        :replace(".zip", "")
        :replace(".tar.gz", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(openssl_dir, pkginfo.install_dir())

    return true
end

function config()
    local binding_tree_version_tag = xpkg_binding_tree .. "@" .. pkginfo.version()
    xvm.add(xpkg_binding_tree)

    local bindir = path.join(pkginfo.install_dir(), "bin")
    local libdir = path.join(pkginfo.install_dir(), "lib64")
    local includedir = path.join(pkginfo.install_dir(), "include")

    log.debug("Registering CLI programs...")
    for _, prog in ipairs(package.programs) do
        xvm.add(prog, {
            bindir = bindir,
            binding = binding_tree_version_tag,
        })
    end

    log.debug("Registering libraries...")
    local config = {
        type = "lib",
        version = package.name .. "-" .. pkginfo.version(),
        bindir = libdir,
        binding = binding_tree_version_tag,
    }

    for _, lib in ipairs(libs) do
        config.alias = lib
        config.filename = lib
        xvm.add(lib, config)
    end

    log.debug("Installing headers to sysroot...")
    if os.isdir(includedir) then
        local sys_includedir = get_sys_usr_includedir()
        local subdirs = os.dirs(path.join(includedir, "*"))
        for _, subdir in ipairs(subdirs) do
            local name = path.filename(subdir)
            local dst = path.join(sys_includedir, name)
            os.tryrm(dst)
            __cp_tree_proot_safe(subdir, dst)
        end

        for _, file in ipairs(list_files(path.join(includedir, "*.h"))) do
            os.execute('cp "' .. file .. '" "' .. sys_includedir .. '/"')
        end
    end

    xvm.add(package.name, { binding = binding_tree_version_tag })
    return true
end

function uninstall()
    xvm.remove(package.name)

    for _, prog in ipairs(package.programs) do
        xvm.remove(prog)
    end

    for _, lib in ipairs(libs) do
        xvm.remove(lib, package.name .. "-" .. pkginfo.version())
    end

    local includedir = path.join(pkginfo.install_dir(), "include")
    if os.isdir(includedir) then
        local sys_includedir = get_sys_usr_includedir()
        local subdirs = os.dirs(path.join(includedir, "*"))
        for _, subdir in ipairs(subdirs) do
            os.tryrm(path.join(sys_includedir, path.filename(subdir)))
        end

        for _, file in ipairs(list_files(path.join(includedir, "*.h"))) do
            os.tryrm(path.join(sys_includedir, path.filename(file)))
        end
    end

    xvm.remove(xpkg_binding_tree)
    return true
end

-- Per-entry walk that replaces `cp -r SRC_DIR DST_PARENT/`.
-- Enumerates the source tree via `find` (the xim libxpkg lua sandbox
-- doesn't expose xmake's os.files / os.filedirs / os.islink), then
-- issues a single absolute-path syscall per entry (mkdir / cp single
-- file / ln symlink) — proot's path translator handles those correctly.
-- The prior `cp -r` per subdir tripped a proot bug where dir-fd-relative
-- openat() issued mid-recursion was mistranslated when the destination
-- subtree already existed in the subos sysroot.
--
-- Symlinks are preserved (readlink + ln -s).
function __cp_tree_proot_safe(src_dir, dst_dir)
    if not os.isdir(src_dir) then return end
    os.mkdir(dst_dir)
    local f = io.popen(string.format(
        [[find "%s" -mindepth 1 \( -type d -o -type l -o -type f \) -printf '%%y\t%%P\n' 2>/dev/null]],
        src_dir
    ))
    if not f then return end
    local entries = {}
    for line in f:lines() do
        local kind, rel = line:match("^(%a)\t(.+)$")
        if kind and rel then table.insert(entries, {kind=kind, rel=rel}) end
    end
    f:close()
    for _, e in ipairs(entries) do
        local src = path.join(src_dir, e.rel)
        local dst = path.join(dst_dir, e.rel)
        if e.kind == "d" then
            os.mkdir(dst)
        elseif e.kind == "l" then
            os.mkdir(path.directory(dst))
            os.tryrm(dst)
            local t = io.popen(string.format([[readlink "%s" 2>/dev/null]], src))
            local target = ""
            if t then target = (t:read("*l") or ""); t:close() end
            target = target:gsub("[\r\n]+$", "")
            if target ~= "" then
                os.execute(string.format([[ln -s "%s" "%s"]], target, dst))
            end
        else
            os.mkdir(path.directory(dst))
            os.cp(src, dst)
        end
    end
end
