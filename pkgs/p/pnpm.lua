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
    return os.iorun("pnpm --version")
end

function install()
    os.iorun("npm install -g pnpm@" .. pkginfo.version)
    return true
end

function uninstall()
    os.iorun("npm uninstall -g pnpm")
    return true
end