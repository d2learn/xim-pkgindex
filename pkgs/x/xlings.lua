package = {
    spec = "1",

    -- base info
    name = "xlings",
    description = [[Xlings | Highly abstract [ package manager ] - "Multi-version management + Everything can be a package"]],
    type = "package",

    authors = {"Sunrisepeak"},
    maintainers = {"d2learn"},
    contributors = "https://github.com/d2learn/xlings/graphs/contributors",
    licenses = {"Apache-2.0"},
    repo = "https://github.com/d2learn/xlings",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"tools", "package-manager", "version-manager"},
    keywords = {"xlings", "package-manager", "version-manager", "dev-tools"},

    programs = { "xlings", "xim", "xinstall" },

    xvm_enable = true,

    xpm = {
        linux = {
            ["latest"] = { ref = "0.3.0" },
            ["0.3.0"] = "XLINGS_RES",
        },
        macosx = {
            ["latest"] = { ref = "0.3.0" },
            ["0.3.0"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.xvm")

function install()
    local xlingsdir = pkginfo.install_file()
        :replace(".zip", "")
        :replace(".tar.gz", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(xlingsdir, pkginfo.install_dir())
    return true
end

function config()
    xvm.add("xlings", {
        bindir = path.join(pkginfo.install_dir(), "bin"),
    })
    return true
end

function uninstall()
    xvm.remove("xlings")
    return true
end
