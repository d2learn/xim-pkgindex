package = {
    spec = "1",
    homepage = "https://pnpm.io",
    name = "pnpm",
    description = "Fast, disk space efficient package manager",
    licenses = {"MIT"},
    type = "package",
    repo = "https://github.com/pnpm/pnpm",
    docs = "https://pnpm.io/motivation",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"package-manager", "typescript"},

    xpm = {
        windows = {
            deps = { "nodejs" },
            ["latest"] = { ref = "9.15.0"},
            ["9.15.0"] = { },
        },
        linux = {
            deps = { "nodejs" },
            ["latest"] = { ref = "9.15.0"},
            ["9.15.0"] = { },
        },
        macosx = {
            deps = { "nodejs" },
            ["latest"] = { ref = "9.15.0"},
            ["9.15.0"] = { },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    local pnpm_installcmd_template = "npm install -g pnpm@%s --prefix %s"
    os.iorun(string.format(pnpm_installcmd_template, pkginfo.version(), pkginfo.install_dir()))
    return true
end

function config()
    print("config xvm...")
    local bindir = pkginfo.install_dir()
    local cfg = {}
    if os.host() == "windows" then
        cfg.alias = "pnpm.cmd"
    else
        bindir = path.join(pkginfo.install_dir(), "bin")
    end
    cfg.bindir = bindir
    xvm.add("pnpm", cfg)
    return true
end

function uninstall()
    xvm.remove("pnpm")
    return true
end