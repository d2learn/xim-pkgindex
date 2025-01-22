package = {
    -- base info
    name = "seeme",
    description = "让别人知道你在干什么",

    authors = "2412322029",
    contributors = "https://github.com/2412322029/seeme",
    license = "",
    repo = "https://github.com/2412322029/seeme",
    docs = "https://github.com/2412322029/seeme",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"web"},
    keywords = {"flask", "python"},

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        windows = {
            deps = {"python@3.12.6"},
            ["latest"] = { ref = "0.0.1" },
            ["0.0.1"] = {
                url = "https://github.com/2412322029/seeme/releases/download/test/seeme-server.zip",
                sha256 = nil
            },
        },
        debain = {
            deps = {"python@3.12.6"},
            ["latest"] = { ref = "0.0.1" },
            ["0.0.1"] = {
                url = "https://github.com/2412322029/seeme/releases/download/test/seeme-server.zip",
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
    if is_host("windows") then
        return os.iorun("python --version")
    else
        return os.iorun("xvm list python")
    end
end

function install()
    print("Installing dependencies from requirements.txt...")
    local install_result = os.exec("pip install -r requirements.txt")
    if install_result == 0 then
        print("Dependencies installed successfully.")
    else
        print("Failed to install dependencies.")
    end
    return true

end

function config()
    -- config xvm
    os.exec(format(
        "xvm add seeme-server %s --path %s",
        pkginfo.version, pkginfo.install_dir
    ))
    return true
end

function uninstall()
    os.exec("xvm remove seeme-server " .. pkginfo.version)
    return true
end