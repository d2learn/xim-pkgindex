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
        debain = {
            deps = {"python@3"},
            ["latest"] = { ref = "0.0.2" },
            ["0.0.2"] = {
                url = "https://github.com/2412322029/seeme/releases/download/pub/seeme-server.zip",
                sha256 = nil
            },
        },
        ubuntu = { ref = "debain" },
        archlinux = { ref = "debain" },
        manjaro = { ref = "debain" },
    },
}

import("xim.base.runtime")

local pkginfo = runtime.get_pkginfo()

function installed()
    return os.iorun("xvm list seeme-server")
end

function install()
    os.tryrm(pkginfo.install_dir) -- 移除可能存在的老代码 
    os.trymv("server", pkginfo.install_dir)
    print("Installing dependencies from requirements.txt...")
    local install_result = os.exec(string.format("pip install -r %s", path.join(pkginfo.install_dir, "requirement.txt"))) 
    --"C:\Users\Public\.xlings_data\xim\xpkgs\seeme\0.0.2\server\requirement.txt"
    cprint("\n${green}use -> seeme-server${clear}\n")
    cprint("\n${green}install seeme-report after${clear}\n")
    return true

end

function config()
    -- config xvm
    os.exec(format(
        [[xvm add seeme-server %s  --alias "python %s"]],
        pkginfo.version, path.join(pkginfo.install_dir, "main.py")
    ))
    return true
end

function uninstall()
    os.exec("xvm remove seeme-server " .. pkginfo.version)
    return true
end