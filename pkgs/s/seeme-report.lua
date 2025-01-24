package = {
    -- base info
    name = "seeme-report",
    description = "让别人知道你在干什么 seeme report端",

    authors = "2412322029",
    contributors = "https://github.com/2412322029/seeme/report",
    license = "",
    repo = "https://github.com/2412322029/seeme/report",
    docs = "https://github.com/2412322029/seeme/report",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {},
    keywords = {"python"},

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        windows = {
            deps = {"python@3.12.6"},
            ["latest"] = { ref = "0.1.2" },
            ["0.1.2"] = {
                url = "https://github.com/2412322029/seeme/releases/download/pub/seeme-report.zip",
                sha256 = nil
            },
        },
        debain = {
            deps = {"python@3.12.6"},
            ["latest"] = { ref = "0.0.2" },
            ["0.0.2"] = {
                url = "https://github.com/2412322029/seeme/releases/download/pub/seeme-report.zip",
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
    return os.iorun("xvm list seeme-report")
end

function install()
    if os.getenv("OS") == "Windows_NT" then
        os.tryrm(pkginfo.install_dir) -- 移除可能存在的老代码
        os.trymv("report", pkginfo.install_dir)
        print("Installing dependencies from requirements.txt...")
        local install_result = os.exec(string.format("pip install -r %s", pkginfo.install_dir .. "\\requirement.txt"))-- for win \\
        if install_result == 0 then
            print("Dependencies installed successfully.")
            print("run seeme-server first")
            print("run it, use -> seeme-report run -u http://127.0.0.1 -k seeme")
            print("run in background, use -> seeme-reportw run -u http://127.0.0.1 -k seeme")
            print("for help use -> seeme-report -h")
        else
            print("Failed to install dependencies.")
        end
    else
        print("Not Supported")
    end
    return true

end

function config()
    -- config xvm
    os.exec(format(
        [[xvm add seeme-report %s --alias "python %s\report.py"]], 
        pkginfo.version, pkginfo.install_dir
    ))
    os.exec(format(
        [[xvm add seeme-reportw %s --alias "pythonw %s\report.py"]],
        pkginfo.version, pkginfo.install_dir
    ))
    return true
end

function uninstall()
    os.exec("xvm remove seeme-report " .. pkginfo.version)
    return true
end