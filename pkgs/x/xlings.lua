package = {
    spec = "1",

    -- base info
    name = "xlings",
    description = [[Xlings | Highly abstract [ package manager ] - "Multi-version management + Everything can be a package"]],
    type = "package",

    authors = {"Sunrisepeak"},
    maintainers = {"d2learn"},
    contributors = "https://github.com/openxlings/xlings/graphs/contributors",
    licenses = {"Apache-2.0"},
    repo = "https://github.com/openxlings/xlings",

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
            ["latest"] = { ref = "0.4.20" },
            ["0.4.20"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.20/xlings-0.4.20-linux-x86_64.tar.gz",
                sha256 = "d7b250bc61019158ff5e1303572d82c2f8e20c36da44bb628cedbc61ebc80748",
            },
            ["0.4.19"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.19/xlings-0.4.19-linux-x86_64.tar.gz",
                sha256 = "fefca02c7aee4f05c4c30b97fca4a5e22b842eab8d8beb802ae1a40d0b442de2",
            },
            ["0.4.17"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.17/xlings-0.4.17-linux-x86_64.tar.gz",
                sha256 = "e34720c0657f010812c0ff4fbb07b23f4f0df9e97078c989c9861720088a8782",
            },
            ["0.4.16"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.16/xlings-0.4.16-linux-x86_64.tar.gz",
                sha256 = "2c3f898ba12cb1311bd57c614fd001b52c6f582818723a24d7999960a09c61d9",
            },
            ["0.4.15"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.15/xlings-0.4.15-linux-x86_64.tar.gz",
                sha256 = "ee3cddb490e345f02551a9ae16adf47bf0424c13eadb9bea453d8e4dea4d4967",
            },
            ["0.4.14"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.14/xlings-0.4.14-linux-x86_64.tar.gz",
                sha256 = "4d5ba18fb5f8b32ec899c43c64719302445fe13eec952629f28cce9d8c400b71",
            },
            ["0.4.13"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.13/xlings-0.4.13-linux-x86_64.tar.gz",
                sha256 = "74be30e988c82b9f2f3c44a48df2ae736aec6ad9ee05558351c3e37ee73088ec",
            },
            ["0.4.12"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.12/xlings-0.4.12-linux-x86_64.tar.gz",
                sha256 = "efccd525bfc5259a6387c40b523a23c2803678a48ecd4285efa6badac15d6338",
            },
            ["0.4.10"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.10/xlings-0.4.10-linux-x86_64.tar.gz",
                sha256 = "7308f5d65fb71773f1e3546be86c720e77ee21509b6a66dcee86ebf0239e8faf",
            },
            ["0.4.8"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.8/xlings-0.4.8-linux-x86_64.tar.gz",
                sha256 = "983b1ce4aa5b0fc4707907a314b5c1944362f141c085e2129a0c0c54cd030451",
            },
            ["0.4.7"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.7/xlings-0.4.7-linux-x86_64.tar.gz",
                sha256 = "e56d7fb5a0a44424ebd48ac4d5cb1f13abe6b296967b910c7ad2ac6e87c79ffd",
            },
            ["0.4.6"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.6/xlings-0.4.6-linux-x86_64.tar.gz",
                sha256 = "b7a61b944f784f0865b1874085f1840432b5a5b0f2b994983ab654ddabde5f9c",
            },
            ["0.4.5"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.5/xlings-0.4.5-linux-x86_64.tar.gz",
                sha256 = "2c1e1605376f0e427adbc0b070250af8843a000e1cb575be81265a7d742d75af",
            },
            ["0.4.4"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.4/xlings-0.4.4-linux-x86_64.tar.gz",
                sha256 = "bea197fe019dacc7062b54994aaa3d77ae92376eb60220d729d2f8e1de8361a6",
            },
            ["0.3.1"] = "XLINGS_RES",
            ["0.3.0"] = "XLINGS_RES",
        },
        macosx = {
            ["latest"] = { ref = "0.4.20" },
            ["0.4.20"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.20/xlings-0.4.20-macosx-arm64.tar.gz",
                sha256 = "647edb71c63a116ef0df57ee4fef944c8063e7d1751272a8d5651917515c423c",
            },
            ["0.4.19"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.19/xlings-0.4.19-macosx-arm64.tar.gz",
                sha256 = "e973a897f2cd785deaab5ad76fd3d37564442483fe5128230c1ea54bbea1dd4f",
            },
            ["0.4.17"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.17/xlings-0.4.17-macosx-arm64.tar.gz",
                sha256 = "2a4237ad4d05302e4af31591a7473cfcbd746077ccc049b92edbedf2dee8317c",
            },
            ["0.4.16"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.16/xlings-0.4.16-macosx-arm64.tar.gz",
                sha256 = "4548743163b8cf7f43ff14f6f4583b516e0b4c62dc824812754799af9836d0c8",
            },
            ["0.4.15"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.15/xlings-0.4.15-macosx-arm64.tar.gz",
                sha256 = "307b5c72d035ffdc87a77efcc0bdb349f68082a7148e7f3d0fb65a7ed03dd640",
            },
            ["0.4.14"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.14/xlings-0.4.14-macosx-arm64.tar.gz",
                sha256 = "fc8747e6fbd32bacb513b467e71fcd4eb5f3457be2eb77d0c18f6b26e2c160b3",
            },
            ["0.4.13"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.13/xlings-0.4.13-macosx-arm64.tar.gz",
                sha256 = "d64625801bba3a6895b3f61b9dd3e4fecac67d2fecfac7379693bf1f2298864d",
            },
            ["0.4.12"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.12/xlings-0.4.12-macosx-arm64.tar.gz",
                sha256 = "2350db515e3c326320a3404a36bf2a7b30705d89028e89130b9456d45c6ddf79",
            },
            ["0.4.10"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.10/xlings-0.4.10-macosx-arm64.tar.gz",
                sha256 = "3b45256592eddf9e47bcaea9e4856183e5d3714fd5684016c04fa7529f889b0f",
            },
            ["0.4.8"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.8/xlings-0.4.8-macosx-arm64.tar.gz",
                sha256 = "a3159b72315bd8f71294b3554c4bde991da857fa87a9aa047ef8abf516a5a94d",
            },
            ["0.4.7"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.7/xlings-0.4.7-macosx-arm64.tar.gz",
                sha256 = "f45df49073c9aba50f211c10954b90726fc747efd383c5cd178a8727a30e5fe1",
            },
            ["0.4.6"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.6/xlings-0.4.6-macosx-arm64.tar.gz",
                sha256 = "c8e653da23a2c56f508b53c4c60066db5cc13b3e45a5897a17630e3d188f76e2",
            },
            ["0.4.5"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.5/xlings-0.4.5-macosx-arm64.tar.gz",
                sha256 = "dd4995cb951c1c45e145b05a57406676590948469a367fd15ce51f2ee7f5e574",
            },
            ["0.4.4"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.4/xlings-0.4.4-macosx-arm64.tar.gz",
                sha256 = "7051d331451e3f1ce9c9a8f35f4e4f14fd96b30912bcc944d46333ca9b6b0b7d",
            },
            ["0.3.1"] = "XLINGS_RES",
            ["0.3.0"] = "XLINGS_RES",
        },
        windows = {
            ["latest"] = { ref = "0.4.20" },
            ["0.4.20"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.20/xlings-0.4.20-windows-x86_64.zip",
                sha256 = "409aa41fc88b831439a8495e7846921e5cc0167ef0987618bcc2dcca80d358d0",
            },
            ["0.4.19"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.19/xlings-0.4.19-windows-x86_64.zip",
                sha256 = "7b1d4be51ea67137d5094eb85661b439b72ed320b13ebc7b36ba679aeb8222d3",
            },
            ["0.4.17"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.17/xlings-0.4.17-windows-x86_64.zip",
                sha256 = "34a2001fbd4a4211e7e658fe70f7476f41b769e8d9f637a8b561c8d93881c0ed",
            },
            ["0.4.16"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.16/xlings-0.4.16-windows-x86_64.zip",
                sha256 = "c57ca9a1ed45f80013f86e4db510a1b565bc146250e02b3a34d6813a93f723b6",
            },
            ["0.4.15"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.15/xlings-0.4.15-windows-x86_64.zip",
                sha256 = "894f2f462fa1d32fb2ca6df5acce460393dfd13b3803d78260cd48886d69dd9a",
            },
            ["0.4.14"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.14/xlings-0.4.14-windows-x86_64.zip",
                sha256 = "92ee06165f7b469ec78a34f5b5b9590d4500cf212e31b24c61f35c653695724a",
            },
            ["0.4.13"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.13/xlings-0.4.13-windows-x86_64.zip",
                sha256 = "6953fc974d241e72de0625d80b15b7250cb071a906a500da5b3c6b410c9df878",
            },
            ["0.4.12"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.12/xlings-0.4.12-windows-x86_64.zip",
                sha256 = "9d600b38a8897e772d6c787df95f9e6e0a13bff3f9c3729bf91ed2f6f66f9e62",
            },
            ["0.4.10"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.10/xlings-0.4.10-windows-x86_64.zip",
                sha256 = "fec7d922d96903b29bfaa59befb241ad87adc059d3f4f3a8dd64fbb46cc532a3",
            },
            ["0.4.8"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.8/xlings-0.4.8-windows-x86_64.zip",
                sha256 = "a1f28b904f79106156de43b5790f7b0338cab1371d2e0ff3eabf7a1636159b2b",
            },
            ["0.4.7"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.7/xlings-0.4.7-windows-x86_64.zip",
                sha256 = "13ecbdac25e5370b97812860aed058e86ac0be6c4a77ebd508a581d2a51172c5",
            },
            ["0.4.6"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.6/xlings-0.4.6-windows-x86_64.zip",
                sha256 = "ed20e4bf2f0b6e4a3c981e87d1c65cec60483350b17e7c5c0f57f1e497aaa8f7",
            },
            ["0.4.5"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.5/xlings-0.4.5-windows-x86_64.zip",
                sha256 = "46a62c229a6b729663e9068782f9ac9ea3b50ad193f8cdb159d90f1c43055d78",
            },
            ["0.4.4"] = {
                url = "https://github.com/openxlings/xlings/releases/download/v0.4.4/xlings-0.4.4-windows-x86_64.zip",
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
