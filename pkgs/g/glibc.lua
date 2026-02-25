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

    programs = {
        "ldd",
        "libc.so", "libc.so.6",
        "ld-linux-x86-64.so.2", "libdl.so.2",
        "libm.so", "libm.so.6", "libmvec.so.1",
        "libpthread.so.0", "libpthread.a",
    },

    xpm = {
        linux = {
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
    "libc.so", "libc.so.6", "libc_nonshared.a", -- C library
    "libdl.a", "libdl.so.2", -- dynamic loading
    "libm.so", "libm.so.6", "libmvec.so.1", -- math
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
    os.cp(glibcdir, pkginfo.install_dir(), {
        force = true, symlink = true
    })

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

    log.info("1 - config glibc tool...")
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
    log.info("2 - config glibc libs...")
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

    log.info("3 - glibc config header files...")

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

    log.info("Copying glibc header files to subos rootfs ...")
    os.cp(include_dir, sysroot_usrdir, {
        force = true, symlink = true
    })
    
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

    log.info("relocate glibc paths (pattern: */%s/%s/lib) -> .", fromsource_glibc, pkginfo.version())

    os.cd(pkginfo.install_dir())

    for _, f in ipairs(relocate_files) do
        if os.isfile(f) then
            log.info("relocate file: " .. f)
            local content = io.readfile(f)
            local new_content, count = content:gsub(path_pattern, ".")
            if count > 0 then
                io.writefile(f, new_content)
            end
        end
    end
end