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

    -- Only `xlings` is registered via xvm.add in config() below.
    -- The other CLI entry points the xlings binary recognizes — `xim`,
    -- `xinstall`, `xsubos`, `xself` — are multicall aliases that
    -- `xlings self init` (xself::ensure_subos_shims) wires up on xlings's
    -- own install side, NOT here. Listing them under `programs` would
    -- make CI's declared-program audit demand a shim from this xpkg's
    -- config(), which it never produces, so they don't belong here.
    programs = { "xlings" },

    xvm_enable = true,

    -- 0.4.4+ is pinned to a direct GitHub release URL so it can be
    -- installed without going through the xlings mirror (XLINGS_RES).
    -- Older versions stay on XLINGS_RES — the mirror still resolves
    -- them, and the new GitHub-direct shape is being introduced
    -- one version at a time.
    xpm = {
        linux = {
            ["latest"] = { ref = "0.4.10" },
            ["0.4.10"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.10/xlings-0.4.10-linux-x86_64.tar.gz",
                sha256 = "7308f5d65fb71773f1e3546be86c720e77ee21509b6a66dcee86ebf0239e8faf",
            },
            ["0.4.8"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.8/xlings-0.4.8-linux-x86_64.tar.gz",
                sha256 = "983b1ce4aa5b0fc4707907a314b5c1944362f141c085e2129a0c0c54cd030451",
            },
            ["0.4.7"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.7/xlings-0.4.7-linux-x86_64.tar.gz",
                sha256 = "e56d7fb5a0a44424ebd48ac4d5cb1f13abe6b296967b910c7ad2ac6e87c79ffd",
            },
            ["0.4.6"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.6/xlings-0.4.6-linux-x86_64.tar.gz",
                sha256 = "b7a61b944f784f0865b1874085f1840432b5a5b0f2b994983ab654ddabde5f9c",
            },
            ["0.4.5"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.5/xlings-0.4.5-linux-x86_64.tar.gz",
                sha256 = "2c1e1605376f0e427adbc0b070250af8843a000e1cb575be81265a7d742d75af",
            },
            ["0.4.4"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.4/xlings-0.4.4-linux-x86_64.tar.gz",
                sha256 = "bea197fe019dacc7062b54994aaa3d77ae92376eb60220d729d2f8e1de8361a6",
            },
            ["0.3.1"] = "XLINGS_RES",
            ["0.3.0"] = "XLINGS_RES",
        },
        macosx = {
            ["latest"] = { ref = "0.4.10" },
            ["0.4.10"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.10/xlings-0.4.10-macosx-arm64.tar.gz",
                sha256 = "3b45256592eddf9e47bcaea9e4856183e5d3714fd5684016c04fa7529f889b0f",
            },
            ["0.4.8"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.8/xlings-0.4.8-macosx-arm64.tar.gz",
                sha256 = "a3159b72315bd8f71294b3554c4bde991da857fa87a9aa047ef8abf516a5a94d",
            },
            ["0.4.7"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.7/xlings-0.4.7-macosx-arm64.tar.gz",
                sha256 = "f45df49073c9aba50f211c10954b90726fc747efd383c5cd178a8727a30e5fe1",
            },
            ["0.4.6"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.6/xlings-0.4.6-macosx-arm64.tar.gz",
                sha256 = "c8e653da23a2c56f508b53c4c60066db5cc13b3e45a5897a17630e3d188f76e2",
            },
            ["0.4.5"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.5/xlings-0.4.5-macosx-arm64.tar.gz",
                sha256 = "dd4995cb951c1c45e145b05a57406676590948469a367fd15ce51f2ee7f5e574",
            },
            ["0.4.4"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.4/xlings-0.4.4-macosx-arm64.tar.gz",
                sha256 = "7051d331451e3f1ce9c9a8f35f4e4f14fd96b30912bcc944d46333ca9b6b0b7d",
            },
            ["0.3.1"] = "XLINGS_RES",
            ["0.3.0"] = "XLINGS_RES",
        },
        windows = {
            ["latest"] = { ref = "0.4.10" },
            ["0.4.10"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.10/xlings-0.4.10-windows-x86_64.zip",
                sha256 = "fec7d922d96903b29bfaa59befb241ad87adc059d3f4f3a8dd64fbb46cc532a3",
            },
            ["0.4.8"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.8/xlings-0.4.8-windows-x86_64.zip",
                sha256 = "a1f28b904f79106156de43b5790f7b0338cab1371d2e0ff3eabf7a1636159b2b",
            },
            ["0.4.7"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.7/xlings-0.4.7-windows-x86_64.zip",
                sha256 = "13ecbdac25e5370b97812860aed058e86ac0be6c4a77ebd508a581d2a51172c5",
            },
            ["0.4.6"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.6/xlings-0.4.6-windows-x86_64.zip",
                sha256 = "ed20e4bf2f0b6e4a3c981e87d1c65cec60483350b17e7c5c0f57f1e497aaa8f7",
            },
            ["0.4.5"] = {
                url = "https://github.com/d2learn/xlings/releases/download/v0.4.5/xlings-0.4.5-windows-x86_64.zip",
                sha256 = "46a62c229a6b729663e9068782f9ac9ea3b50ad193f8cdb159d90f1c43055d78",
            },
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
