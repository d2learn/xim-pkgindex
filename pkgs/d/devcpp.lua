package = {
    name = "devcpp",
    description = "Dev-C++: A full-featured Integrated Development Environment (IDE) for the C/C++",
    homepage = "https://sourceforge.net/projects/orwelldevcpp/",
    maintainers = "Orwell (Johan Mes)",
    licenses = "GPL",
    repo = "https://sourceforge.net/projects/orwelldevcpp/",
    docs = "https://forum.d2learn.org/topic/134",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"ide", "c", "c++"},
    keywords = {"dev-cpp"},

    programs = { "devcpp" },

    xpm = {
        windows = {
            deps = { "shortcut-tool" },
            ["latest"] = { ref = "5.11" },
            ["5.11"] = {
                url = "https://gitcode.com/xlings-res/dev-cpp/releases/download/5.11/dev-cpp-5.11-windows-x86_64.zip",
                sha256 = nil,
            },
            ["chinese"] = {
                url = "https://gitcode.com/xlings-res/dev-cpp/releases/download/chinese/dev-cpp-chinese-windows-x86_64.zip",
                sha256 = nil,
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.system")
import("xim.libxpkg.log")

--local appdata_devcpp = path.join(os.getenv("APPDATA"), "Roaming", "Dev-Cpp")
local appdata_devcpp = path.join(os.getenv("APPDATA"), "Dev-Cpp")

function install()
    os.tryrm(pkginfo.install_dir())
    local devcpp_dir = pkginfo.install_file()
        :replace(".zip", "")
    os.mv(devcpp_dir, pkginfo.install_dir())
    return true
end

function config()
    xvm.add("devcpp")
    system.exec(string.format(
        [[shortcut-tool create --name "Dev-C++ 5.11" --target "%s" --icon "%s"]],
        path.join(pkginfo.install_dir(), "devcpp.exe"),
        path.join(pkginfo.install_dir(), "devcpp.exe")
    ))

    if pkginfo.version() == "chinese" then
        log.info("config Dev-C++ to use Chinese settings...")
        log.info("config-file-dir: " .. appdata_devcpp)
        os.tryrm(appdata_devcpp)
        os.mkdir(appdata_devcpp)
        os.cp(path.join(pkginfo.install_dir(), "devcpp.ini"), path.join(appdata_devcpp, "devcpp.ini"))
        os.cp(path.join(pkginfo.install_dir(), "codeinsertion.ini"), path.join(appdata_devcpp, "codeinsertion.ini"))
    end

    cprint([[${yellow}

           ConfigDoc | 配置文档
    https://forum.d2learn.org/topic/134

    ]])

    return true
end

function uninstall()
    xvm.remove("devcpp")
    system.exec(string.format(
        [[shortcut-tool remove --name "Dev-C++ 5.11"]]
    ))
    os.tryrm(appdata_devcpp)
    return true
end