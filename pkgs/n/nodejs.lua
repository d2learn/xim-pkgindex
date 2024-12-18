package = {
    homepage = "https://nodejs.org",
    name = "nodejs",
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
            ["latest"] = { ref = "22.12.0"},
            ["22.12.0"] = {
                url = "https://nodejs.org/dist/v22.12.0/node-v22.12.0-win-x64.zip",
                sha256 = "2b8f2256382f97ad51e29ff71f702961af466c4616393f767455501e6aece9b8",
            },
        },
        ubuntu = {
            ["latest"] = { ref = "22.12.0"},
            ["22.12.0"] = {
                url = "https://nodejs.org/dist/v22.12.0/node-v22.12.0-linux-x64.tar.xz",
                sha256 = "22982235e1b71fa8850f82edd09cdae7e3f32df1764a9ec298c72d25ef2c164f",
            },
        },
        debian = { ref = "ubuntu" },
    },
}

import("xim.base.utils")
import("xim.base.runtime")

local pkginfo = runtime.get_pkginfo()

local node_dir = {
    linux = "node-v22.12.0-linux-x64",
    windows = "node-v22.12.0-win-x64",
}

function installed()
    return os.iorun("node --version")
end

function install()
    local bindir = path.join(
        path.directory(pkginfo.install_file),
        node_dir[os.host()]
    )
    bindir = path.join(bindir, "bin")
    utils.add_env_path(bindir)
    return true
end

function uninstall()
    os.tryrm(node_dir[os.host()])
    return true
end