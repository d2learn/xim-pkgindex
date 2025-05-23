package = {
    -- base info

    homepage = "https://github.com/d2learn/xim-pkgindex",

    name = "cpp",
    description = "C++ language toolchain",
    maintainers = "xim team",
    contributors = "https://github.com/d2learn/xim-pkgindex/graphs/contributors",

    -- xim pkg info
    type = "config",
    status = "stable", -- dev, stable, deprecated
    categories = {"plang", "compiler", "c"},

    xpm = {
        windows = {
            deps = {"msvc@2022"},
            ["latest"] = { ref = "msvc" },
            ["msvc"] = {},
        },
        linux = {
            deps = {"gcc"},
            ["latest"] = { ref = "gnu" },
            ["gnu"] = {},
        },
    },
}

import("core.tool.toolchain")

import("xim.libxpkg.pkginfo")
import("xim.xuninstall")

function installed()
    if pkginfo.version() == "msvc" then
        return toolchain.load("msvc"):check() == "2022"
    elseif pkginfo.version() == "gnu" then
        local output = os.iorun("gcc --version")
        return string.find(output:trim(), "gcc", 1, true) ~= nil
    else
        return true
    end
end

function install()
    -- install by deps
    return true
end

function uninstall()
    if pkginfo.version() == "msvc" then
        xuninstall("msvc")
    elseif pkginfo.version() == "gnu" then
        xuninstall("gcc")
    end
    return true
end