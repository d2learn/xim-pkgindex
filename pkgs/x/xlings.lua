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

    -- 0.4.4 is pinned to a direct GitHub release URL so it can be
    -- installed without going through the xlings mirror (XLINGS_RES).
    -- Older versions stay on XLINGS_RES — the mirror still resolves
    -- them, and the new GitHub-direct shape is being introduced
    -- one version at a time.
    xpm = {
        linux = {
            ["latest"] = { ref = "0.4.4" },
            ["0.4.4"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.4/xlings-0.4.4-linux-x86_64.tar.gz",
                sha256 = "bea197fe019dacc7062b54994aaa3d77ae92376eb60220d729d2f8e1de8361a6",
            },
            ["0.3.1"] = "XLINGS_RES",
            ["0.3.0"] = "XLINGS_RES",
        },
        macosx = {
            ["latest"] = { ref = "0.4.4" },
            ["0.4.4"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.4/xlings-0.4.4-macosx-arm64.tar.gz",
                sha256 = "7051d331451e3f1ce9c9a8f35f4e4f14fd96b30912bcc944d46333ca9b6b0b7d",
            },
            ["0.3.1"] = "XLINGS_RES",
            ["0.3.0"] = "XLINGS_RES",
        },
        windows = {
            ["latest"] = { ref = "0.4.4" },
            ["0.4.4"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.4/xlings-0.4.4-windows-x86_64.zip",
                sha256 = "45a1f6271d23d3386c713340069e8638559520d5bfc5517ef8eb33e1bea2b577",
            },
            ["0.3.1"] = "XLINGS_RES",
            ["0.3.0"] = "XLINGS_RES",
        }
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
