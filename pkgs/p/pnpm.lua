package = {
    homepage = "https://pnpm.io",
    name = "pnpm",
    description = "Fast, disk space efficient package manager",
    licenses = "MIT",
    repo = "https://github.com/pnpm/pnpm",
    docs = "https://pnpm.io/motivation",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"package-manager", "typescript"},

    xpm = {
        windows = {
            deps = { "nodejs@22.12.0" },
            ["latest"] = { ref = "9.15.0"},
            ["9.15.0"] = { },
        },
        ubuntu = {
            deps = { "nodejs@22.12.0" },
            ["latest"] = { ref = "9.15.0"},
            ["9.15.0"] = { },
        },
        debian = { ref = "ubuntu" },
        archlinux = { ref = "ubuntu" },
    },
}

import("xim.base.runtime")

local pkginfo = runtime.get_pkginfo()

function installed()
    return os.iorun("xvm list pnpm")
end

function install()
    os.iorun("npm install -g pnpm@" .. pkginfo.version)
    local node_path = os.iorun("npm root -g")
    -- get up level directory
    node_path = path.directory(node_path)
    node_path = path.directory(node_path)
    node_bin_path = path.join(node_path, "bin")

    print("node_bin_path: ", node_bin_path)
    os.exec(string.format("xvm add pnpm %s --path %s", pkginfo.version, node_bin_path))

    return true
end

function uninstall()
    os.exec("npm uninstall -g pnpm@" .. pkginfo.version)
    os.exec("xvm remove pnpm " .. pkginfo.version)
    return true
end