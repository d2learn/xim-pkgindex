function download_url(version)
    if is_host("windows") then
        return string.format("https://nodejs.org/dist/v%s/node-v%s-win-x64.zip", version, version)
    elseif is_host("macosx") then
        return string.format("https://nodejs.org/dist/v%s/node-v%s-darwin-arm64.tar.gz", version, version)
    else
        return string.format("https://nodejs.org/dist/v%s/node-v%s-linux-x64.tar.xz", version, version)
    end
end

-- xpkg info

package = {
    homepage = "https://nodejs.org",
    name = "node",
    description = "Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine",
    author = "Node.js Foundation",
    licenses = "MIT",
    repo = "https://github.com/nodejs/node",
    docs = "https://nodejs.org/docs",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"nodejs", "javascript"},

    xpm = {
        windows = {
            ["latest"] = { ref = "22.17.1" },
            ["24.4.1"] = { url = download_url("24.4.1"), sha256 = nil, },
            ["23.6.0"] = { url = download_url("23.6.0"), sha256 = nil, },
            ["22.17.1"] = { url = download_url("22.17.1"), sha256 = nil, },
            ["22.12.0"] = {
                url = "https://nodejs.org/dist/v22.12.0/node-v22.12.0-win-x64.zip",
                sha256 = "2b8f2256382f97ad51e29ff71f702961af466c4616393f767455501e6aece9b8",
            },
        },
        linux = {
            ["latest"] = { ref = "22.17.1" },
            ["24.4.1"] = { url = download_url("24.4.1"), sha256 = nil, },
            ["23.11.0"] = { url = download_url("23.11.0"), sha256 = nil, },
            ["23.6.0"] = { url = download_url("23.6.0"), sha256 = nil, },
            ["22.17.1"] = { url = download_url("22.17.1"), sha256 = nil, },
            ["22.14.0"] = { url = download_url("22.14.0"), sha256 = nil, },
            ["22.12.0"] = {
                url = "https://nodejs.org/dist/v22.12.0/node-v22.12.0-linux-x64.tar.xz",
                sha256 = "22982235e1b71fa8850f82edd09cdae7e3f32df1764a9ec298c72d25ef2c164f",
            },
            ["20.19.0"] = { url = download_url("20.19.0"), sha256 = nil, },
            ["18.20.8"] = { url = download_url("18.20.8"), sha256 = nil, },
        },
        macosx = {
            ["latest"] = { ref = "22.17.1" },
            ["24.4.1"] = { url = download_url("24.4.1"), sha256 = nil, },
            ["23.11.0"] = { url = download_url("23.11.0"), sha256 = nil, },
            ["23.6.0"] = { url = download_url("23.6.0"), sha256 = nil, },
            ["22.17.1"] = { url = download_url("22.17.1"), sha256 = nil, },
            ["22.14.0"] = { url = download_url("22.14.0"), sha256 = nil, },
            ["22.12.0"] = { url = download_url("22.12.0"), sha256 = nil, },
            ["20.19.0"] = { url = download_url("20.19.0"), sha256 = nil, },
            ["18.20.8"] = { url = download_url("18.20.8"), sha256 = nil, },
        },
    },
}

import("xim.base.utils")
import("xim.libxpkg.pkginfo")

local node_dir_template = {
    linux = "node-v%s-linux-x64",
    windows = "node-v%s-win-x64",
    macosx = "node-v%s-darwin-arm64",
}

function install()
    os.tryrm(pkginfo.install_dir())
    print("Installing Node.js to %s ...", pkginfo.install_dir())
    os.mv(
        string.format(node_dir_template[os.host()], pkginfo.version()),
        pkginfo.install_dir()
    )
    return true
end

function config()
    print("Configuring Node.js ...")
    local node_xvm_cmd_template1 = "xvm add node %s --path %s"
    local node_xvm_cmd_template2 = "xvm add nodejs %s --path %s --alias node"
    local npm_xvm_cmd_template = "xvm add npm node-%s --path %s"
    local npx_xvm_cmd_template = "xvm add npx node-%s --path %s"

    local bindir = pkginfo.install_dir()
    if is_host("windows") then
        npm_xvm_cmd_template = npm_xvm_cmd_template .. " --alias npm.cmd"
        npx_xvm_cmd_template = npx_xvm_cmd_template .. " --alias npx.cmd"
    else
        bindir = path.join(pkginfo.install_dir(), "bin")
    end

    os.exec(string.format(node_xvm_cmd_template1, pkginfo.version(), bindir))
    os.exec(string.format(node_xvm_cmd_template2, pkginfo.version(), bindir))
    os.exec(string.format(npm_xvm_cmd_template, pkginfo.version(), bindir))
    os.exec(string.format(npx_xvm_cmd_template, pkginfo.version(), bindir))
    return true
end

function uninstall()
    print("Uninstalling Node.js from %s ...", pkginfo.install_dir())
    os.exec("xvm remove node " .. pkginfo.version())
    os.exec("xvm remove nodejs " .. pkginfo.version())
    os.exec("xvm remove npm node-" .. pkginfo.version())
    os.exec("xvm remove npx node-" .. pkginfo.version())
    return true
end