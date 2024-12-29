package = {
    homepage = "https://project-graph.top",
    name = "project-graph",
    description = "快速绘制节点图的桌面工具 - 项目进程拓扑图绘制、头脑风暴草稿",

    maintainers = "LiRenTech",
    contributors = "https://github.com/LiRenTech/project-graph/graphs/contributors",
    licenses = "MIT",
    repo = "https://github.com/LiRenTech/project-graph",
    docs = "https://project-graph.top/getting-started",
    forum = "https://forum.d2learn.org/category/16/project-graph",

    -- xim pkg info
    archs = {"x86_64", "aarch64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"desktop-tools", "graph-tools"},

    xpm = {
        windows = {
            ["latest"] = { ref = "1.1.0" },
            ["nightly"] = {
                url = "%.exe$", -- url pattern
                github_release_tag = "nightly",
            },
            ["1.1.0"] = {
                url = "https://github.com/LiRenTech/project-graph/releases/download/v1.1.0/Project.Graph_1.1.0_x64-setup.exe",
                sha256 = nil,
            },
            ["1.0.0"] = { 
                url = "https://github.com/LiRenTech/project-graph/releases/download/v1.0.0/Project.Graph_1.0.0_x64-setup.exe",
                sha256 = nil,
            }
        },
        debian = {
            ["latest"] = { ref = "1.1.0" },
            ["nightly"] = {
                url = "%.deb$", -- url pattern
                github_release_tag = "nightly",
            },
            ["1.1.0"] = {
                url = "https://github.com/LiRenTech/project-graph/releases/download/v1.1.0/Project.Graph_1.1.0_amd64.deb",
                sha256 = "220ffb27c20f15008b77138612a237eefea22691638f09b351d276085af02d32",
            },
            ["1.0.0"] = {
                url = "https://github.com/LiRenTech/project-graph/releases/download/v1.0.0/Project.Graph_1.0.0_amd64.deb",
                sha256 = nil,
            },
        },
        ubuntu = { ref = "debian" },
        archlinux = { ref = "debian" },
    },
}

import("platform")
import("xim.base.utils")
import("xim.base.runtime")

local datadir = runtime.get_xim_data_dir()
local bindir = platform.get_config_info().bindir
local pkginfo = runtime.get_pkginfo()
local os_info = utils.os_info()

local binname = {
    windows = "project-graph.exe",
    linux = "project-graph",
}

function installed()
    if os.host() == "windows" then
        local pgraph_exe_file = "C:\\Users\\" .. os.getenv("USERNAME") .. "\\AppData\\Local\\Project Graph\\project-graph.exe"
        return os.isfile(pgraph_exe_file)
    else
        return os.iorun("which project-graph") ~= nil
    end
end

function install()
    if os.host() == "windows" then
        common.xlings_exec(pkginfo.install_file .. " /SILENT")
    elseif os.host() == "linux" then
        if os_info.name == "archlinux" then
            -- https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD
            os.exec("mkdir -p project-graph && cd project-graph")
            os.exec("ar x " .. pkginfo.install_file)
            os.exec("tar -xvf data.tar.xz")
            os.cp("usr/bin/project-graph", bindir)
            os.exec("gtk-update-icon-cache -q -t -f usr/share/icons/hicolor")
            os.exec("update-desktop-database -q")
        else
            os.exec("sudo dpkg -i " .. pkginfo.install_file)
        end
    end
    return true
end

function uninstall()
    if os.host() == "windows" then
        common.xlings_exec("C:\\Users\\" .. os.getenv("USERNAME") .. "\\AppData\\Local\\Project Graph\\uninstall.exe /SILENT")
    elseif os.host() == "linux" then
        if os_info.name == "archlinux" then
            os.tryrm(path.join(bindir, binname.linux))
            os.tryrm(path.join(datadir, "project-graph"))
            os.exec("update-desktop-database -q")
        else
            os.exec("sudo dpkg -r project-graph")
        end
    end
    return true
end