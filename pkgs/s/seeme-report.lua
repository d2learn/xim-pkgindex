package = {
    -- base info
    name = "seeme-report",
    description = "让别人知道你在干什么 seeme report端",

    authors = "2412322029",
    contributors = "https://github.com/2412322029/seeme",
    license = "",
    repo = "https://github.com/2412322029/seeme",
    docs = "https://github.com/2412322029/seeme",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {},
    keywords = {"python"},

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        windows = {
            deps = {"python@3"},
            ["latest"] = { ref = "0.0.2" },
            ["0.0.2"] = {
                url = "https://github.com/2412322029/seeme/releases/download/pub/seeme-report.zip",
                sha256 = nil
            },
        },
    },
}

import("xim.base.runtime")

local pkginfo = runtime.get_pkginfo()

function installed()
    return os.iorun("xvm list seeme-report")
end

function install()
    os.tryrm(pkginfo.install_dir) -- 移除可能存在的老代码
    os.trymv("report", pkginfo.install_dir)
    print("Installing dependencies from requirements.txt...")
    local install_result = os.exec(string.format("pip install -r %s", path.join(pkginfo.install_dir, "requirement.txt")))-- for win \\
    cprint("\n${green}run seeme-server first${clear}")
    cprint("\n${green}run it, use -> seeme-report run${clear} ")
    cprint("\n${green}run in background, use -> seeme-reportw run${clear}")
    cprint("\n${green}for help use -> seeme-report -h${clear}")

    return true

end

function config()
    -- config xvm
    os.exec(format(
        [[xvm add seeme-report %s --alias "python %s" --env REPORT_KEY="seeme" --env REPORT_URL="http://127.0.0.1"]], 
        pkginfo.version, path.join(pkginfo.install_dir, "report.py")
    ))
    os.exec(format(
        [[xvm add seeme-reportw %s --alias "pythonw %s" --env REPORT_KEY="seeme" --env REPORT_URL="http://127.0.0.1"]],
        pkginfo.version, path.join(pkginfo.install_dir, "report.py")
    ))
    return true
end

function uninstall()
    os.exec("xvm remove seeme-report " .. pkginfo.version)
    os.exec("xvm remove seeme-reportw " .. pkginfo.version)
    return true
end