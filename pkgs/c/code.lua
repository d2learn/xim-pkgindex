local _vscode_linux_url_template = "https://update.code.visualstudio.com/%s/linux-x64/stable"
local _vscode_windows_url_template = "https://update.code.visualstudio.com/%s/win32-x64-archive/stable"
local _vscode_macosx_url_template = "https://update.code.visualstudio.com/%s/darwin-universal/stable"

function _vscode_url(version)
    local platform_url = nil
    if is_host("windows") then
        platform_url = string.format(_vscode_windows_url_template, version)
    elseif is_host("linux") then
        platform_url = string.format(_vscode_linux_url_template, version)
    else -- macosx
        platform_url = string.format(_vscode_macosx_url_template, version)
    end

    return {
        url = platform_url,
        sha256 = nil,
    }
end

package = {
    spec = "1",
    homepage = "https://code.visualstudio.com",

    name = "code",
    description = "Visual Studio Code",
    contributors = "https://github.com/microsoft/vscode/graphs/contributors",
    licenses = {"MIT"},
    repo = "https://github.com/microsoft/vscode",
    docs = "https://code.visualstudio.com/docs",

    type = "package",
    status = "stable",
    categories = { "editor", "tools" },
    keywords = { "vscode", "cross-platform" },
    date = "2024-9-01",

    xpm = {
        windows = {
            ["latest"] = { ref = "1.108.0" },
            ["1.108.1"] = _vscode_url("1.108.1"),
            ["1.108.0"] = _vscode_url("1.108.0"),
            ["1.106.1"] = _vscode_url("1.106.1"),
            ["1.100.1"] = _vscode_url("1.100.1"),
            ["1.96.2"] = {
                url = string.format(_vscode_windows_url_template, "1.96.2"),
                sha256 = "c6c2f97e5cb25a8b576b345f6b8f2021cc168f1726ee370f29d1dbd136ffe9f8",
            },
            ["1.93.1"] = _vscode_url("1.93.1"),
        },
        linux = {
            ["latest"] = { ref = "1.108.0" },
            ["1.108.1"] = _vscode_url("1.108.1"),
            ["1.108.0"] = _vscode_url("1.108.0"),
            ["1.106.1"] = _vscode_url("1.106.1"),
            ["1.100.1"] = _vscode_url("1.100.1"),
            ["1.96.2"] = _vscode_url("1.96.2"),
            ["1.93.1"] = _vscode_url("1.93.1"),
        },
        macosx = { ref = "linux" }
    }
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.xvm")

local shortcut_dir = {
    linux = tostring(os.getenv("HOME")) .. "/.local/share/applications",
    windows = tostring(os.getenv("APPDATA")) .. "/Microsoft/Windows/Start Menu/Programs"
}

local shortcut_template = {
    linux = [[
[Desktop Entry]
Name=Visual Studio Code - [%s]
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=%s
Icon=%s
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=TextEditor;Development;IDE;
MimeType=application/x-code-workspace;
Actions=new-empty-window;
Keywords=vscode;
]],
    windows = [[
TODO
]],
}

function installed()
    return os.iorun("xvm list code")
end

function install()
    if os.host() == "windows" then
        os.tryrm(pkginfo.install_dir())
        -- unzip the stable by powershell
        os.mv("stable", "stable.zip")
        -- avoid warning info by -ExecutionPolicy Bypass
        os.exec(string.format([[powershell -ExecutionPolicy Bypass -Command "Expand-Archive -Path stable.zip -DestinationPath %s -Force"]], pkginfo.install_dir()))
        os.tryrm("stable.zip")
    elseif os.host() == "macosx" then
        os.exec("unzip stable")
        os.mv("Visual Studio Code.app", pkginfo.install_dir())
        os.tryrm("stable")
    else
        os.exec("tar -xvf stable")
        os.tryrm(pkginfo.install_dir())
        os.exec("mv VSCode-linux-x64 " .. pkginfo.install_dir())
        -- https://github.com/flathub/com.visualstudio.code/issues/223
        -- set the correct permissions for chrome-sandbox, and as root
        print("https://github.com/flathub/com.visualstudio.code/issues/223")
        print("setting permissions for chrome-sandbox...")
        os.exec("sudo chown root:root " .. pkginfo.install_dir() .. "/chrome-sandbox")
        os.exec("sudo chmod 4755 " .. pkginfo.install_dir() .. "/chrome-sandbox")
        os.tryrm("stable")
    end
    return true
end

function config()
    local xvm_cmd_template1 = [[xvm add code %s --path "%s/bin" --alias %s]]
    local xvm_cmd_template2 = [[xvm add vscode %s --path "%s/bin" --alias %s]]
    local code_alias = "code"
    local appdir = pkginfo.install_dir()

    -- config desktop entry
    if os.host() == "windows" then
        code_alias = "code.cmd"
        -- create desktop shortcut
        local lnk_filename = "Visual Studio Code - [" .. pkginfo.version() .. "]"
        create_windows_shortcut(
            lnk_filename,
            path.join(pkginfo.install_dir(), "code.exe"),
            path.join(pkginfo.install_dir(), "code.exe"),
            pkginfo.install_dir()
        )
        os.cp(lnk_filename .. ".lnk", path.join("C:/Users", os.getenv("USERNAME"), "Desktop"))
        os.mv(lnk_filename .. ".lnk", shortcut_dir[os.host()])
    elseif os.host() == "macosx" then
        appdir = path.join(pkginfo.install_dir(), "Visual Studio Code.app")
        -- xattr for macosx
        system.exec([[xattr -rd com.apple.quarantine "]] .. appdir .. [["]])
        -- TODO: add lsregister to libxpkg.system
        -- register app(for first time)
        -- Info.plist CFBundleIdentifier is com.microsoft.VSCode
        local lsregister = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
        system.exec(lsregister .. [[ -f "]] .. appdir .. [["]])
        -- Contents/Resources/app
        appdir = path.join(appdir, "Contents", "Resources", "app")
    else
        local desktop_info = desktop_shortcut_info()
        if not os.isfile(desktop_info.filepath) then
            print("creating desktop shortcut...")
            io.writefile(desktop_info.filepath, desktop_info.content)
        end
    end

    xvm.add("code", { bindir = path.join(appdir, "bin"), alias = code_alias })
    xvm.add("vscode", { bindir = path.join(appdir, "bin"), alias = code_alias, binding = "code@" .. pkginfo.version() })

    return true
end

function uninstall()
    xvm.remove("code")
    xvm.remove("vscode")
    if os.host() == "windows" then
        -- remove desktop shortcut
        local lnk_filename = "Visual Studio Code - [" .. pkginfo.version() .. "]"
        local lnk_path = path.join(shortcut_dir[os.host()], lnk_filename .. ".lnk")
        print("removing desktop shortcut - %s", lnk_path)
        os.tryrm(path.join("C:/Users", os.getenv("USERNAME"), "Desktop", lnk_filename .. ".lnk"))
        os.tryrm(lnk_path)
    elseif os.host() == "macosx" then
        -- TODO: clean cache files?
    else
        local desktop_info = desktop_shortcut_info()
        if os.isfile(desktop_info.filepath) then
            print("removing desktop shortcut - %s", desktop_info.filepath)
            os.tryrm(desktop_info.filepath)
        end
    end
    return true
end

---

function desktop_shortcut_info()
    local filename = "vscode." .. pkginfo.version() .. ".xvm.desktop"
    local filepath = path.join(shortcut_dir[os.host()], filename)
    local exec_path = string.format("%s/bin/code", pkginfo.install_dir())
    local icon_path = string.format("%s/resources/app/resources/linux/code.png", pkginfo.install_dir())

    return {
        filepath = filepath,
        content = string.format(
            shortcut_template[os.host()],
            pkginfo.version(), exec_path, icon_path
        )
    }
end

function create_windows_shortcut(name, target, icon, working_dir, arguments)
    -- 创建一个 .vbs 脚本的内容
    local vbs_content = string.format([[
Set WshShell = WScript.CreateObject("WScript.Shell")
Set shortcut = WshShell.CreateShortcut("%s.lnk")
shortcut.TargetPath = "%s"
shortcut.IconLocation = "%s"
shortcut.WorkingDirectory = "%s"
shortcut.Arguments = "%s"
shortcut.Description = "Shortcut for %s"
shortcut.Save
    ]], name, target, icon, working_dir, arguments or "", name)

    -- 保存为一个临时 .vbs 文件
    local vbs_path = "vscode.xim.vbs"
    local file = io.open(vbs_path, "w")
    file:write(vbs_content)
    file:close()

    -- 执行 .vbs 文件以创建快捷方式
    os.exec("wscript " .. vbs_path)

    -- 删除临时的 .vbs 文件
    os.tryrm(vbs_path)

    print("Shortcut created: " .. name .. ".lnk")
end