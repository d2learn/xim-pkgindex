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
            deps = { "glibc@2.39" },
            ["latest"] = { ref = "3.1.5" },
            ["3.1.5"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")
import("xim.libxpkg.elfpatch")

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

    -- Point interpreter directly to glibc xpkgs
    local glibc_dir = pkginfo.dep_install_dir("glibc", "2.39")
    local loader = glibc_dir and path.join(glibc_dir, "lib64", "ld-linux-x86-64.so.2") or nil
    elfpatch.auto({
        enable = true,
        shrink = true,
        bins = { "bin" },
        libs = { "lib64" },
        interpreter = loader,
    })
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
            os.execute('cp -r "' .. subdir .. '" "' .. dst .. '"')
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
