-- TODO: "debain" 拼写错误，应为 "debian"；同时使用了旧 API import("xim.base.runtime")，建议迁移到 import("xim.libxpkg.pkginfo")

package = {
    spec = "1",
    -- base info
    name = "seeme-server",
    description = "让别人知道你在干什么 seeme 服务端",

    authors = {"2412322029"},
    contributors = "https://github.com/2412322029/seeme",
    licenses = {""},
    repo = "https://github.com/2412322029/seeme",
    docs = "https://github.com/2412322029/seeme",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"web"},
    keywords = {"flask", "python"},

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        windows = {
            deps = {"python@3"},
            ["latest"] = { ref = "0.0.2" },
            ["0.0.2"] = {
                url = "https://github.com/2412322029/seeme/releases/download/pub/seeme-server.zip",
                sha256 = nil
            },
        },
        debian = {
            deps = {"python@3"},
            ["latest"] = { ref = "0.0.2" },
            ["0.0.2"] = {
                url = "https://github.com/2412322029/seeme/releases/download/pub/seeme-server.zip",
                sha256 = nil
            },
        },
        ubuntu = { ref = "debian" },
        archlinux = { ref = "debian" },
        manjaro = { ref = "debian" },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function installed()
    return os.iorun("xvm list seeme-server")
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.trymv("server", pkginfo.install_dir())
    print("Installing dependencies from requirements.txt...")
    os.exec(string.format("pip install -r %s", path.join(pkginfo.install_dir(), "requirement.txt")))
    cprint("\n${green}use -> seeme-server${clear}\n")
    cprint("\n${green}install seeme-report after${clear}\n")
    return true
end

function config()
    xvm.add("seeme-server", {
        alias = "python " .. path.join(pkginfo.install_dir(), "main.py"),
    })
    return true
end

function uninstall()
    xvm.remove("seeme-server")
    return true
end