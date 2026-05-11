package = {
    spec = "1",

    homepage = "https://www.gnu.org/software/libc",
    -- base info
    name = "glibc",
    description = "The GNU C Library",

    authors = {"GNU"},
    licenses = {"GPL"},
    repo = "https://sourceware.org/git/?p=glibc.git;a=summary",
    docs = "https://www.gnu.org/doc/doc.html",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"libc", "gnu"},
    keywords = {"libc", "gnu"},

    -- xvm: xlings version management
    xvm_enable = true,

    -- Only `ldd` is a CLI shim. The .so / .a files are libs registered
    -- via `xvm.add(name, { type = "lib", ... })` in config() below — they
    -- live in glibc's xvm version DB, not in subos/default/bin, so they
    -- don't belong in `programs` (which is the CLI-shim audit list).
    programs = { "ldd" },

    xpm = {
        linux = {
            -- Declare the dynamic linker we ship so consumers don't have
            -- to hardcode `path.join(glibc_dir, "lib64", "ld-linux-x86-64.so.2")`
            -- in their own install hooks. xlings predicate-driven elfpatch
            -- (regenerated post 2026-05-02 design) reads this and patches
            -- consumer ELFs automatically. `abi` is the disambiguation tag
            -- when a subos hosts both glibc and musl xpkgs.
            exports = {
                runtime = {
                    loader = "lib64/ld-linux-x86-64.so.2",
                    abi    = "linux-x86_64-glibc",
                    -- libdirs not declared → falls back to {lib64, lib} convention
                },
            },
            ["latest"] = { ref = "2.39" },
            ["2.39"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.log")
import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.xvm")

-- libnss modules
local glibc_libs = {
    "crt1.o", "crti.o", "crtn.o", -- crt
    "ld-linux-x86-64.so.2", -- dynamic linker/loader
    "libc.a", "libc.so", "libc.so.6", "libc_nonshared.a", -- C library
    "libdl.a", "libdl.so.2", -- dynamic loading
    "libm.a", "libm-2.39.a", "libmvec.a", "libm.so", "libm.so.6", "libmvec.so.1", -- math
    "libpthread.so.0", "libpthread.a", -- pthread
    "librt.so.1", -- realtime
    "libresolv.so", "libresolv.so.2", -- resolver
    -- libnss modules
    "libnss_compat.so",
    "libnss_compat.so.2",
    "libnss_dns.so.2",
    "libnss_files.so.2",
    "libnss_hesiod.so",
    "libnss_hesiod.so.2",
    "libnss_db.so",
    "libnss_db.so.2",
    -- 
    "libnsl.so.1",

    -- rust-lld: error: cannot open Scrt1.o: No such file or directory
    -- rust-lld: error: unable to find library -lutil
    -- rust-lld: error: unable to find library -lrt
    "Scrt1.o",
    "libutil.a", "libutil.so.1",
    "librt.a", "librt.so.1",
}

function install()

    local glibcdir = pkginfo.install_file():replace(".tar.gz", "")

    os.tryrm(pkginfo.install_dir())
    os.mv(glibcdir, pkginfo.install_dir())

    log.info("Relocating glibc files(path) ...")
    __relocate()

    return true
end

function config()
    xvm.add("glibc")

    local glibc_root_binding = "glibc@" .. pkginfo.version()
    local glibc_version = "glibc-" .. pkginfo.version()
    local glibc_bindir = path.join(pkginfo.install_dir(), "bin")
    local glibc_libdir = path.join(pkginfo.install_dir(), "lib64")

    log.debug("1 - config glibc tool...")
    local bin_config = {
        version = glibc_version,
        bindir = glibc_bindir,
        binding = glibc_root_binding,
        envs = {
            --["LD_LIBRARY_PATH"] = glibc_libdir,
            --["LD_RUN_PATH"] = glibc_libdir,
        }
    }

    xvm.add("ldd", bin_config)

-- lib
    log.debug("2 - config glibc libs...")
    local lib_config = {
        version = glibc_version,
        type = "lib",
        bindir = glibc_libdir,
        binding = glibc_root_binding,
    }

    for _, lib in ipairs(glibc_libs) do
        lib_config.filename = lib -- target file name
        lib_config.alias = lib -- source file name
        xvm.add(lib, lib_config)
    end

    log.debug("3 - glibc config header files...")

    __config_header()

    return true
end

function uninstall()
    local glibc_version = "glibc-" .. pkginfo.version()
    for _, lib in ipairs(glibc_libs) do
        xvm.remove(lib, glibc_version)
    end
    xvm.remove("ldd", glibc_version)
    xvm.remove("glibc")
    return true
end

-- private

function __config_header()
    local include_dir = path.join(pkginfo.install_dir(), "include")

    -- link headers to system include path
    -- TODO: add include support for xlings (use sysroot)
    local subos_sysrootdir = system.subos_sysrootdir()
    local sysroot_usrdir = path.join(subos_sysrootdir, "usr")
    if not os.isdir(sysroot_usrdir) then os.mkdir(sysroot_usrdir) end

    -- Skip the recursive header copy if a previous install of the same
    -- version already placed it. config() runs on every dependent xpkg
    -- install (any package that lists glibc@<ver> in deps), so without
    -- this gate, every install of xim:gcc / fromsource:* re-cp's the
    -- entire glibc include tree (~thousand files) — wasted I/O + log
    -- spam. Same fix shape as linux-headers (commit 3718532).
    local stamp = path.join(sysroot_usrdir, ".glibc-" .. pkginfo.version() .. ".stamp")
    if os.isfile(stamp) then
        log.debug("glibc headers already in subos rootfs (stamp present), skipping copy.")
        return
    end

    log.info("Copying glibc header files to subos rootfs ...")
    __cp_tree_proot_safe(include_dir, path.join(sysroot_usrdir, "include"))
    io.writefile(stamp, pkginfo.version())
end

-- Per-entry walk that replaces `cp -r SRC_DIR DST_PARENT/` (and xmake's
-- recursive os.cp on a directory). Enumerates the source tree via
-- `find` (the xim libxpkg lua sandbox doesn't expose xmake's
-- os.files / os.filedirs / os.islink — even openssl.lua here resorts to
-- io.popen('ls -d')), then issues a single absolute-path syscall per
-- entry (mkdir / cp single file / ln symlink) — which proot's path
-- translator handles correctly. The previous `cp -r` tripped a proot
-- bug where `openat(parent_fd, "<child>", ...)` issued by coreutils
-- mid-recursion was mistranslated, failing the copy when the
-- destination subtree already existed in the subos sysroot.
--
-- Symlinks are preserved (readlink + ln -s), matching `symlink = true`
-- on xmake's recursive os.cp and `cp -d`/`cp -a`.
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

function __relocate()

    local relocate_files = {
        "lib/libc.so",
        "lib/libm.so",
        "lib/libm.a",

        "bin/ldd",
        "bin/tzselect",
        "bin/xtrace",
        "bin/sotruss",
    }

--[[
  Prebuilt tarball contains absolute paths from build machine (e.g. /home/xlings/.xlings_data/...).
  Must replace ANY path ending with fromsource-x-glibc/VERSION/lib, not just current install path.
]]

    local fromsource_glibc = "fromsource-x-" .. package.name
    local version_escaped = pkginfo.version():gsub("%.", "%%.")
    -- Match any absolute path ending with fromsource-x-glibc/VERSION/lib (build path varies by machine)
    local path_pattern = "([^%s)]+)/" .. fromsource_glibc:gsub("-", "%%-") .. "/" .. version_escaped .. "/lib"

    local base = pkginfo.install_dir()
    log.info("relocate glibc paths (pattern: */%s/%s/lib) -> .", fromsource_glibc, pkginfo.version())

    for _, f in ipairs(relocate_files) do
        local abs_f = path.join(base, f)
        if os.isfile(abs_f) then
            log.info("relocate file: " .. f)
            local content = io.readfile(abs_f)
            local new_content, count = content:gsub(path_pattern, ".")
            if count > 0 then
                io.writefile(abs_f, new_content)
            end
        end
    end
end