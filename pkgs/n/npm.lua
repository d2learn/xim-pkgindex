package = {
    homepage = "https://www.npmjs.com",
    name = "npm",
    description = "The package manager for JavaScript",
    licenses = "Artistic License 2.0",
    repo = "https://github.com/npm/cli",
    docs = "https://docs.npmjs.com/cli",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"package-manager", "javascript"},

    xpm = {
        windows = {
            deps = { "nodejs" },
            ["latest"] = { ref = "11.0.0" },
            ["11.0.0"] = { },
            ["10.9.2"] = { },
        },
        linux = {
            deps = { "nodejs" },
            ["latest"] = { ref = "11.0.0" },
            ["11.0.0"] = { },
            ["10.9.2"] = { },
        },
        debian = { ref = "linux" },
        ubuntu = { ref = "linux" },
        archlinux = { ref = "linux" },
        manjaro = { ref = "linux" },
    },
}

import("xim.base.runtime")

local pkginfo = runtime.get_pkginfo()

function installed()
    return os.iorun("xvm list npm")
end

function install()
    local npm_installcmd_template = "npm install -g npm@%s --prefix %s"
    os.iorun(string.format(npm_installcmd_template, pkginfo.version, pkginfo.install_dir))
    return true
end

function config()
    print("config xvm...")
    local xvm_npm_template = "xvm add npm %s --path %s/bin"
    os.exec(string.format(xvm_npm_template, pkginfo.version, pkginfo.install_dir))
    return true
end

function uninstall()
    os.exec("xvm remove npm " .. pkginfo.version)
    return true
end