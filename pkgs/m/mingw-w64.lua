
function __mingw_cn_mirror_url(version) return format("https://gitcode.com/xlings-res/mingw-w64/releases/download/%s/mingw-w64-%s-windows-x86_64.zip", version, version) end

package = {
    -- base info
    name = "mingw-w64",
    description = "A complete runtime environment for GCC & LLVM for Windows",

    licenses = "ZPL 2.1",
    contributors = "https://github.com/mingw-w64/mingw-w64/graphs/contributors",
    repo = "https://github.com/mingw-w64/mingw-w64",
    homepage = "https://mingw-w64.org",
    docs = "https://www.winlibs.com",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"mingw", "cross-platform", "runtime"},
    keywords = {"gcc", "runtime", "c", "c++", "mingw", "llvm"},

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        windows = {
            ["latest"] = { ref = "13.0.0" },
            ["13.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/brechtsanders/winlibs_mingw/releases/download/15.1.0posix-13.0.0-ucrt-r2/winlibs-x86_64-posix-seh-gcc-15.1.0-mingw-w64ucrt-13.0.0-r2.zip",
                    CN = __mingw_cn_mirror_url("13.0.0"),
                },
                sha256 = nil
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

local gcc_version_map = {
    ["13.0.0"] = "15.1.0",
}

function installed()
    local installdir = pkginfo.install_dir()
    return os.isfile(path.join(installdir, "mingw64", "version_info.txt"))
end

function install()
    local mingwdir = pkginfo.install_file()
        :replace(".tar.gz", "")
        :replace(".zip", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(mingwdir, pkginfo.install_dir())
    return true
end

function config()
    local mingw_bindir = path.join(pkginfo.install_dir(), "mingw64", "bin")

    local config = {
        bindir = mingw_bindir,
    }

    xvm.add("x86_64-w64-mingw32-gcc", config)
    xvm.add("x86_64-w64-mingw32-g++", config)
    xvm.add("x86_64-w64-mingw32-c++", config)

    config.version = string.format([[%s(mingw-64-%s)]],
        gcc_version_map[pkginfo.version], pkginfo.version
    )
    xvm.add("gcc", config)
    xvm.add("c++", config)
    xvm.add("g++", config)

    return true
end

function uninstall()
    xvm.remove("x86_64-w64-mingw32-gcc")
    xvm.remove("x86_64-w64-mingw32-g++")
    xvm.remove("x86_64-w64-mingw32-c++")

    local version = string.format([[%s(mingw-64-%s)]],
        gcc_version_map[pkginfo.version], pkginfo.version
    )
    xvm.remove("gcc", version)
    xvm.remove("g++", version)
    xvm.remove("c++", version)

    return true
end