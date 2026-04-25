package = {
    spec = "1",

    name = "xmake",
    description = "A cross-platform build utility based on Lua",

    authors = {"ruki"},
    maintainers = {"ruki"},
    licenses = {"Apache-2.0"},
    repo = "https://github.com/xmake-io/xmake",
    homepage = "https://xmake.io",
    docs = "https://xmake.io/#/getting_started",

    type = "package",
    archs = {"x86_64", "aarch64"},
    status = "stable",
    categories = {"build-system", "tools"},
    keywords = {"xmake", "build", "lua", "cross-platform"},

    programs = {"xmake"},
    xvm_enable = true,

    xpm = {
        linux = {
            url_template = "https://github.com/xmake-io/xmake/releases/download/v{version}/xmake-bundle-v{version}.linux.x86_64",
            ["latest"] = { ref = "3.0.7" },
            ["3.0.7"] = {
                url = "https://github.com/xmake-io/xmake/releases/download/v3.0.7/xmake-bundle-v3.0.7.linux.x86_64",
                sha256 = nil,
            },
            -- ["3.0.7"] = "XLINGS_RES",
        },
        macosx = {
            url_template = "https://github.com/xmake-io/xmake/releases/download/v{version}/xmake-bundle-v{version}.macos.arm64",
            ["latest"] = { ref = "3.0.7" },
            ["3.0.7"] = {
                url = "https://github.com/xmake-io/xmake/releases/download/v3.0.7/xmake-bundle-v3.0.7.macos.arm64",
                sha256 = nil,
            },
            -- ["3.0.7"] = "XLINGS_RES",
        },
        windows = {
            url_template = "https://github.com/xmake-io/xmake/releases/download/v{version}/xmake-bundle-v{version}.win64.exe",
            ["latest"] = { ref = "3.0.7" },
            ["3.0.7"] = {
                url = "https://github.com/xmake-io/xmake/releases/download/v3.0.7/xmake-bundle-v3.0.7.win64.exe",
                sha256 = nil,
            },
            -- ["3.0.7"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    local exe_name = "xmake"
    if os.host() == "windows" then
        exe_name = "xmake.exe"
    else
        os.exec("chmod +x " .. pkginfo.install_file())
    end

    os.mv(pkginfo.install_file(), path.join(pkginfo.install_dir(), exe_name))
    return true
end

function config()
    xvm.add("xmake")
    return true
end

function uninstall()
    xvm.remove("xmake")
    return true
end
