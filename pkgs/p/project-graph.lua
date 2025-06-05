function _linux_donwload_url(version) return string.format("https://github.com/LiRenTech/project-graph/releases/download/v%s/Project.Graph_%s_amd64.deb", version, version) end

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
    type = "package", -- package, config
    archs = {"x86_64", "aarch64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"desktop-tools", "graph-tools"},
    keywords = { "project", "topology", "drawing", "graph" },

    xpm = {
        windows = {
            ["latest"] = { ref = "1.2.7" },
            ["nightly"] = {
                url = "%.exe$", -- url pattern
                github_release_tag = "nightly",
            },
            ["1.2.7"] = {
                url = "https://github.com/LiRenTech/project-graph/releases/download/v1.2.7/Project.Graph_1.2.7_x64-setup.exe",
                sha256 = nil,
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
        linux = {
            deps = { "webkit2gtk" },
            ["latest"] = { ref = "1.7.10" },
            ["nightly"] = {
                url = "%.deb$", -- url pattern
                github_release_tag = "nightly",
            },
            ["1.7.10"] = { url = _linux_donwload_url("1.7.10"), sha256 = nil },
            ["1.7.0"] = { url = _linux_donwload_url("1.7.0"), sha256 = nil },
            ["1.6.0"] = { url = _linux_donwload_url("1.6.0"), sha256 = nil },
            ["1.5.1"] = { url = _linux_donwload_url("1.5.1"), sha256 = nil },
            ["1.5.0"] = { url = _linux_donwload_url("1.5.0"), sha256 = nil },
            ["1.4.0"] = { url = _linux_donwload_url("1.4.0"), sha256 = nil },
            ["1.2.7"] = { url = _linux_donwload_url("1.2.7"), sha256 = nil },
            ["1.2.6"] = { url = _linux_donwload_url("1.2.6"), sha256 = nil },
            ["1.2.5"] = { url = _linux_donwload_url("1.2.5"), sha256 = nil },
            ["1.2.0"] = { url = _linux_donwload_url("1.2.0"), sha256 = nil },
            ["1.1.0"] = {
                url = "https://github.com/LiRenTech/project-graph/releases/download/v1.1.0/Project.Graph_1.1.0_amd64.deb",
                sha256 = "220ffb27c20f15008b77138612a237eefea22691638f09b351d276085af02d32",
            },
            ["1.0.0"] = {
                url = "https://github.com/LiRenTech/project-graph/releases/download/v1.0.0/Project.Graph_1.0.0_amd64.deb",
                sha256 = nil,
            },
        },
    },
}

import("common")
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
    return os.iorun("xvm list project-graph")
end

function install()
    if os.host() == "windows" then
        print("安装tips:")
        print("\t 0.打开安装提示")
        print("\t 1.选择对应语言")
        print("\t 2.点击“下一步”直到安装完成")
        common.xlings_exec(pkginfo.install_file .. " /SILENT")
    elseif os.host() == "linux" then
        os.tryrm("project-graph")
        os.tryrm(pkginfo.install_dir)
        os.mkdir("project-graph")
        os.cd("project-graph")
        os.exec("ar x " .. pkginfo.install_file)
        os.exec("tar -xvf data.tar.gz")
        os.mv("usr", pkginfo.install_dir)
        os.tryrm(pkginfo.install_file)
    end
    return true
end

function config()
    local xvm_cmd_template = [[xvm add project-graph %s --path "%s"]]
    local project_graph_path = path.join(pkginfo.install_dir, "bin")
    if os.host() == "windows" then
        -- TODO: support multi-version for windows
        print("remove old version...")
        os.exec("xvm remove project-graph --yes") -- remove old version
        project_graph_path = "C:\\Users\\" .. os.getenv("USERNAME") .. "\\AppData\\Local\\Project Graph"
    else
        _config_desktop_shortcut("create")
    end
    os.exec(string.format(xvm_cmd_template, pkginfo.version, project_graph_path))
    return true
end

function uninstall()
    local xvm_rm = "xvm remove project-graph "
    if os.host() == "windows" then
        common.xlings_exec("\"C:\\Users\\" .. os.getenv("USERNAME") .. "\\AppData\\Local\\Project Graph\\uninstall.exe\"")
        utils.prompt("等待卸载/waiting uninstall...")
        os.exec(xvm_rm)
    elseif os.host() == "linux" then
        _config_desktop_shortcut("delete")
        os.exec(xvm_rm .. pkginfo.version)
    end
    return true
end

function _config_desktop_shortcut(action)
    action = action or "delete" -- create, delete
    if os.host() == "linux" then
        local filename = "project-graph-" .. pkginfo.version .. ".xvm.desktop"
        local shortcut_file = path.join(os.getenv("HOME"), ".local/share/applications", filename)
        local desktop_entry = [[
[Desktop Entry]
Name=Project Graph - [%s]
Comment=Diagram creator
Exec=%s
Icon=%s
Type=Application
StartupNotify=false
StartupWMClass=project-graph
        ]]

        print("[%s] - %s", action, shortcut_file)

        if action == "create" then
            io.writefile(filename, string.format(
                desktop_entry,
                pkginfo.version,
                path.join(pkginfo.install_dir, "bin", "project-graph"),
                path.join(pkginfo.install_dir, "share/icons/hicolor/128x128/apps/project-graph.png"
            )))
            os.mv(filename, shortcut_file)
        elseif action == "delete" then
            os.tryrm(shortcut_file)
        end
    end
end