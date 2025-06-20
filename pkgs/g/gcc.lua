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

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = "XLINGS_RES",
            ["14.2.0"] = { url = __gcc_url("14.2.0") },
            ["13.3.0"] = { url = __gcc_url("13.3.0") },
            ["12.4.0"] = { url = __gcc_url("12.4.0") },
            ["11.5.0"] = { url = __gcc_url("11.5.0") },
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

local mingw_version_map {
    ["15.1.0"] = "13.0.0",
}

function install()
    if is_host("windows") then
        xinstall("mingw-w64@" .. mingw_version_map[pkginfo.version])
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
    if is_host("windows") then return true end

    local gcc_bindir = path.join(pkginfo.install_dir(), "bin")
    local ld_lib_path = string.format("%s:%s", path.join(pkginfo.install_dir(), "lib64"), os.getenv("LD_LIBRARY_PATH") or "")
    
    local config = {
        bindir = gcc_bindir,
        envs = {
            ["LD_LIBRARY_PATH"] = ld_lib_path,
        }
    }

    xvm.add("gcc", config)
    if is_host("macosx") then config.alias = "gcc-15" end
    xvm.add("g++", config)
    if is_host("macosx") then config.alias = "g++-15" end
    xvm.add("c++", config)
    if is_host("macosx") then config.alias = "c++-15" end

    return true
end

function uninstall()
    if is_host("windows") then
        xuninstall("mingw-w64@" .. mingw_version_map[pkginfo.version])
    else
        xvm.remove("gcc")
        xvm.remove("g++")
        xvm.remove("c++")
    end
    return true
end