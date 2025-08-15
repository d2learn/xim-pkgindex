function __gcc_url(version) return format("https://ftp.gnu.org/gnu/gcc/gcc-%s/gcc-%s.tar.xz", version, version) end

package = {
    -- base info
    name = "gcc",
    description = "GCC, the GNU Compiler Collection",

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
        "gcc", "g++", "c++", "cpp",
        "addr2line", "ar", "as", "ld", "nm",
        "objcopy", "objdump", "ranlib", "readelf",
        "size", "strings", "strip",
    },

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            -- toolchain build based on musl-gcc-static
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = "XLINGS_RES",
        },
        macosx = {
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = "XLINGS_RES",
        },
        windows = {
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = { },
        },
    },
}

import("xim.xinstall")
import("xim.xuninstall")
import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")

local mingw_version_map = {
    ["15.1.0"] = "13.0.0",
}

function install()
    if is_host("windows") then
        xinstall("mingw-w64@" .. mingw_version_map[pkginfo.version()])
    else
        local gccdir = pkginfo.install_file()
            :replace(".tar.gz", "")
            :replace(".zip", "")
        os.tryrm(pkginfo.install_dir())
        os.mv(gccdir, pkginfo.install_dir())
    end
    return true
end

function config()
    if is_host("windows") then
        return true
    elseif is_host("macosx") then
        log.warn("TODO: macOS support for GCC is not implemented yet.")
        return false
    elseif is_host("linux") then
        local gcc_bindir = path.join(pkginfo.install_dir(), "bin")
    
        log.info("add [ gcc, g++, c++, cpp, addr2line, ar, as, ld, nm, objcopy, objdump, ranlib, readelf, size, strings, strip ... ] commands")
        for _, prog in ipairs(package.programs) do
            xvm.add(prog, {
                bindir = gcc_bindir,
                alias = "x86_64-linux-musl-" .. prog,
            })
        end

-- runtime lib
        log.warn("add runtime libraries for musl-gcc-static...")
        local musl_lib_dir = path.join(
            pkginfo.install_dir(),
            "x86_64-linux-musl", "lib"
        )

        -- add musl's libc libc.so
        xvm.add("libc", {
            version = "gcc-" .. pkginfo.version(),
            filename = "libc.so",
            bindir = musl_lib_dir,
            type = "lib",
            alias = "libc.so",
        })

        -- add ld.so (musl's ld.so wrapper)
        xvm.add("ld-musl", {
            version = "gcc-" .. pkginfo.version(),
            filename = "ld-musl-x86_64.so.1",
            bindir = musl_lib_dir,
            type = "lib",
            alias = "libc.so",
        })

-- special commands
        log.warn("add [ ldd ] (ld-musl-x86_64.so.1 --list)")
        xvm.add("ldd", {
            version = "gcc-" .. pkginfo.version(),
            bindir = musl_lib_dir,
            alias = "libc.so --list",
            envs = {
                -- ? alias = "libc.so --library-path musl_lib_dir --list",
                LD_LIBRARY_PATH = musl_lib_dir,
            }
        })

        log.warn("add [ musl-loader ] (ld-musl-x86_64.so.1)")
        xvm.add("musl-loader", {
            version = "gcc-" .. pkginfo.version(),
            bindir = musl_lib_dir,
            alias = "libc.so",
            envs = {
                -- ? alias = "libc.so --library-path musl_lib_dir",
                LD_LIBRARY_PATH = musl_lib_dir,
            }
        })

        return true
    end
end

function uninstall()
    if is_host("windows") then
        xuninstall("mingw-w64@" .. mingw_version_map[pkginfo.version()])
    elseif is_host("linux") then
        for _, prog in ipairs(package.programs) do
            xvm.remove(prog)
        end
        xvm.remove("libc", "gcc-" .. pkginfo.version())
        xvm.remove("ld-musl", "gcc-" .. pkginfo.version())
        xvm.remove("ldd", "gcc-" .. pkginfo.version())
        xvm.remove("musl-loader", "gcc-" .. pkginfo.version())
    end
    return true
end