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
        "gcc-static", "g++-static",
        "gcc", "g++", "c++", "cpp",
        "addr2line", "ar", "as", "ld", "nm",
        "objcopy", "objdump", "ranlib", "readelf",
        "size", "strings", "strip",
        "ldd", "loader", -- -> musl-ldd -> musl-lic.so
    },

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            --deps = { "musl-gcc" },
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = { }, -- deps musl-gcc
            ["13.3.0"] = { },
            ["11.5.0"] = { },
            ["9.4.0"] = { },
        },
        macosx = {
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = { }, --"XLINGS_RES",
        },
        windows = {
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = { },
        },
    },
}

import("xim.libxpkg.pkgmanager")
import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")

local mingw_version_map = {
    ["15.1.0"] = "13.0.0",
}

function install()
    if is_host("windows") then
        pkgmanager.install("mingw-w64@" .. mingw_version_map[pkginfo.version()])
    elseif is_host("linux") then
        pkgmanager.install("musl-gcc@" .. pkginfo.version())
    elseif is_host("macosx") then
        log.warn("TODO: macOS support for GCC is not implemented yet.")
        return false
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

        log.info("add [ gcc, g++, c++, cpp, addr2line, ar, as, ld, nm, objcopy, objdump, ranlib, readelf, size, strings, strip ... ] commands")
        for _, prog in ipairs(package.programs) do
            xvm.add(prog, {
                version = "musl-gcc-" .. pkginfo.version(),
                alias = "musl-" .. prog,
            })
        end

        return true
    end
end

function uninstall()
    if is_host("windows") then
        xuninstall("mingw-w64@" .. mingw_version_map[pkginfo.version()])
    elseif is_host("linux") then
        for _, prog in ipairs(package.programs) do
            xvm.remove(prog, "musl-gcc-" .. pkginfo.version())
        end
    end
    return true
end