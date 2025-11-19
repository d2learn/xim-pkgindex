package = {
    -- base info
    name = "d2x",
    description = "xlings's d2x tool",

    authors = "Sunrisepeak",
    licenses = "Apache 2.0",
    repo = "https://github.com/d2learn/d2x",

    -- xim pkg info
    type = "package",

    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"d2x", "tool"},
    keywords = {"d2x", "tool"},

    programs = { "d2x" },

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            ["latest"] = { ref = "0.0.4" },
            ["0.0.4"] = {
                url = "https://github.com/d2learn/d2x.git",
            }, -- "XPKG_LOCAL",
        },
        windows = { ref = "linux" },
        macosx = { ref = "linux" },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    os.tryrm(pkginfo.install_dir())
    os.mv("d2x", pkginfo.install_dir())
    return true
end

function config()

    local main_file = path.join(pkginfo.install_dir(), "src/d2x.lua")

    xvm.add("d2x", {
        alias = "xlings script " .. main_file
    })

    return true
end

function uninstall()
    xvm.remove("d2x")
end