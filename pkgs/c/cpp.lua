package = {
    spec = "1",
    -- base info

    homepage = "https://github.com/d2learn/xim-pkgindex",

    name = "cpp",
    description = "C++ language toolchain",
    maintainers = {"xim team"},
    contributors = "https://github.com/d2learn/xim-pkgindex/graphs/contributors",

    -- xim pkg info
    type = "config",
    status = "stable", -- dev, stable, deprecated
    categories = { "plang", "compiler", "c" },

    xpm = {
        windows = {
            deps = { "mingw-w64@13" },
            ["latest"] = { ref = "mingw" },
            ["mingw"] = {},
            ["msvc"] = {},
        },
        linux = {
            deps = { "gcc" },
            ["latest"] = { ref = "gnu" },
            ["gnu"] = {},
        },
        macosx = {
            deps = { "brew" },
            ["latest"] = {},
        },
    },
}

import("core.tool.toolchain")

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.pkgmanager")

function installed()
    if is_host("macosx") then
        local output = os.iorun("gcc --version")
        if not output then
            output = os.iorun("clang --version")
        end
        return output ~= nil
    elseif pkginfo.version() == "msvc" then
        return toolchain.load("msvc"):check() == "2022"
    elseif pkginfo.version() == "mingw" or pkginfo.version() == "gnu" then
        local output = os.iorun("gcc --version")
        return string.find(output:trim(), "gcc", 1, true) ~= nil
    else
        return true
    end
end

function install()
    if is_host("macosx") then
        system.exec("brew install gcc", { retry = 3 })
    elseif pkginfo.version() == "msvc" then
        pkgmanager.install("msvc@2022")
    else
        -- install by deps
    end
    return true
end

function uninstall()
    if is_host("macosx") then
        system.exec("brew uninstall gcc")
    elseif pkginfo.version() == "msvc" then
        pkgmanager.uninstall("msvc@2022")
    elseif pkginfo.version() == "mingw" then
        pkgmanager.uninstall("mingw-w64@13")
    elseif pkginfo.version() == "gnu" then
        pkgmanager.uninstall("gcc")
    end
    return true
end
