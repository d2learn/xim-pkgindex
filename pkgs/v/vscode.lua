local _vscode_linux_url_template = "https://update.code.visualstudio.com/%s/linux-x64/stable"

package = {
    homepage = "https://code.visualstudio.com",

    name = "vscode",
    description = "Visual Studio Code",
    contributors = "https://github.com/microsoft/vscode/graphs/contributors",
    license = "MIT",
    repo = "https://github.com/microsoft/vscode",
    docs = "https://code.visualstudio.com/docs",

    status = "stable",
    categories = { "editor", "tools" },
    keywords = { "vscode", "cross-platform" },
    date = "2024-9-01",

    xpm = {
        linux = {
            ["latest"] = { ref = "1.96.2" },
            ["1.96.2"] = {
                url = string.format(_vscode_linux_url_template, "1.96.2"),
                sha256 = "2681040089faf143bed37246f2b0bc0787f6d342d878b1ec4b3737b38833c088"
            },
            ["1.93.1"] = {
                url = string.format(_vscode_linux_url_template, "1.93.1"),
                sha256 = nil,
            },
        },
        debian = { ref = "linux" },
        ubuntu = { ref = "linux" },
        archlinux = { ref = "linux" },
        manjaro = { ref = "linux" },
    }
}

import("xim.base.runtime")

local pkginfo = runtime.get_pkginfo()

function installed()
    return os.iorun("xvm list code")
end

function install()
    os.exec("tar -xvf stable")
    os.tryrm(pkginfo.install_dir)
    os.exec("mv VSCode-linux-x64 " .. pkginfo.install_dir)
    -- https://github.com/flathub/com.visualstudio.code/issues/223
    -- set the correct permissions for chrome-sandbox, and as root
    print("https://github.com/flathub/com.visualstudio.code/issues/223")
    print("setting permissions for chrome-sandbox...")
    os.exec("sudo chown root:root " .. pkginfo.install_dir .. "/chrome-sandbox")
    os.exec("sudo chmod 4755 " .. pkginfo.install_dir .. "/chrome-sandbox")
    os.tryrm("stable")
    return true
end

function config()
    local xvm_cmd_template1 = "xvm add code %s --path %s/bin"
    local xvm_cmd_template2 = "xvm add vscode %s --path %s/bin --alias code --icon %s/resources/app/resources/linux/code.png"
    os.exec(string.format(xvm_cmd_template1, pkginfo.version, pkginfo.install_dir))
    os.exec(string.format(xvm_cmd_template2, pkginfo.version, pkginfo.install_dir, pkginfo.install_dir))
    return true
end

function uninstall()
    os.exec("xvm remove code " .. pkginfo.version)
    os.exec("xvm remove vscode " .. pkginfo.version)
    return true
end
