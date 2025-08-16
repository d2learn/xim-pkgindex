package = {
    -- base info
    name = "musl-gcc",
    description = "GCC, the GNU Compiler Collection ( prebuild with musl )",

    authors = "GNU",
    licenses = "GPL",
    repo = "https://github.com/gcc-mirror/gcc",
    docs = "https://gcc.gnu.org/wiki",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"compiler", "gnu", "language"},
    keywords = {"compiler", "gnu", "gcc", "language", "c", "c++"},

    programs = {
        -- "musl-gcc-static", "musl-g++-static",
        "musl-gcc", "musl-g++", "musl-c++", "musl-cpp",
        "musl-addr2line", "musl-ar", "musl-as", "musl-ld", "musl-nm",
        "musl-objcopy", "musl-objdump", "musl-ranlib", "musl-readelf",
        "musl-size", "musl-strings", "musl-strip",
    },

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            -- toolchain build based on musl-gcc-static
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = XLINGS_RES, -- deps musl-gcc
            ["13.3.0"] = XLINGS_RES,
            ["11.5.0"] = XLINGS_RES,
            ["9.4.0"] = XLINGS_RES,
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")


function install()
    local gccdir = pkginfo.install_file()
        :replace(".tar.gz", "")
        :replace(".zip", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(gccdir, pkginfo.install_dir())
    return true
end

function config()
    local gcc_bindir = path.join(pkginfo.install_dir(), "bin")

    for _, prog in ipairs(package.programs) do
        xvm.add(prog, {
            bindir = gcc_bindir,
            alias = "x86_64-linux-" .. prog,
        })
    end

-- runtime lib
    log.warn("add runtime libraries for musl-gcc-static...")
    local musl_lib_dir = path.join(
        pkginfo.install_dir(),
        "x86_64-linux-musl", "lib"
    )

    -- add musl's libc libc.so and libstdc++.so.6 , libgcc_s.so.1
    xvm.add("musl-libc", {
        version = "musl-gcc-" .. pkginfo.version(),
        filename = "libc.so",
        bindir = musl_lib_dir,
        type = "lib",
        alias = "libc.so",
    })

    xvm.add("libstdc++", {
        version = "musl-gcc-" .. pkginfo.version(),
        filename = "libstdc++.so.6",
        bindir = musl_lib_dir,
        type = "lib",
        alias = "libstdc++.so.6",
    })

    xvm.add("libgcc_s", {
        version = "musl-gcc-" .. pkginfo.version(),
        filename = "libgcc_s.so.1",
        bindir = musl_lib_dir,
        type = "lib",
        alias = "libgcc_s.so.1",
    })

    -- add ld.so (musl's ld.so wrapper)
    xvm.add("ld-musl", {
        version = "musl-gcc-" .. pkginfo.version(),
        filename = "ld-musl-x86_64.so.1",
        bindir = musl_lib_dir,
        type = "lib",
        alias = "libc.so",
    })

-- special commands
    xvm.add("musl-ldd", {
        version = "musl-gcc-" .. pkginfo.version(),
        bindir = musl_lib_dir,
        alias = "libc.so --list",
        envs = {
            -- ? alias = "libc.so --library-path musl_lib_dir --list",
            LD_LIBRARY_PATH = musl_lib_dir,
        }
    })

    xvm.add("musl-loader", {
        version = "musl-gcc-" .. pkginfo.version(),
        bindir = musl_lib_dir,
        alias = "libc.so",
        envs = {
            -- ? alias = "libc.so --library-path musl_lib_dir",
            LD_LIBRARY_PATH = musl_lib_dir,
        }
    })

    log.info("add static wrapper for musl-gcc ...")
    xvm.add("musl-gcc-static", { alias = "musl-gcc -static" })
    xvm.add("musl-g++-static", { alias = "musl-g++ -static" })

    return true
end

function uninstall()
    for _, prog in ipairs(package.programs) do
        xvm.remove(prog)
    end
    -- runtime libraries
    xvm.remove("musl-libc", "musl-gcc-" .. pkginfo.version())
    xvm.remove("ld-musl", "musl-gcc-" .. pkginfo.version())
    xvm.remove("libstdc++", "musl-gcc-" .. pkginfo.version())
    xvm.remove("libgcc_s", "musl-gcc-" .. pkginfo.version())
    -- ld.so wrapper
    xvm.remove("musl-ldd", "musl-gcc-" .. pkginfo.version())
    xvm.remove("musl-loader", "musl-gcc-" .. pkginfo.version())
    xvm.remove("musl-gcc-static")
    xvm.remove("musl-g++-static")
    return true
end