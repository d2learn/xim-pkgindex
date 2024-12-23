package = {
    name = "nvm",
    description = "Node Version Manager",
    homepage = "https://github.com/nvm-sh/nvm",
    author = "Tim Caswell",
    maintainers = "https://github.com/nvm-sh/nvm?tab=readme-ov-file#maintainers",
    licenses = "MIT",
    repo = "https://github.com/nvm-sh/nvm",
    docs = "https://github.com/nvm-sh/nvm#installing-and-updating",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"tools", "nodejs"},

    xpm = {
        windows = {
            ["latest"] = { ref = "1.1.11"},
            ["1.1.11"] = {
                url = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.11/nvm-setup.exe",
                sha256 = "941561b7486cffc5b5090a99f6949bdc31dbaa6288025d4b2b1e3f710f0ed654",
            }
        },
        ubuntu = {
            ["latest"] = { ref = "0.39.0"},
            ["0.39.0"] = {
                url = "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh",
                sha256 = nil,
            },
        },
        archlinux = {
            ["latest"] = { ref = "0.40.1" },
            ["0.40.1"] = {
                url = "https://aur.archlinux.org/nvm.git",
                sha256 = nil,
            }
        }
    },
}

import("xim.base.utils")
import("xim.base.runtime")

local pkginfo = runtime.get_pkginfo()

function installed()
    return os.iorun("nvm --version")
end

function install()
    if is_host("windows") then
        os.exec(pkginfo.install_file .. " /SILENT")

        local nvm_home = "C:\\Users\\" .. os.getenv("USERNAME") .. "\\AppData\\Roaming\\nvm"
        local node_home = "C:\\Program Files\\nodejs"

        os.setenv("NVM_HOME", nvm_home)
        os.setenv("NVM_SYMLINK", node_home)

        -- update path
        os.addenv("PATH", nvm_home)
        os.addenv("PATH", node_home)
    elseif utils.os_info().name == "archlinux" then
        os.cd("nvm")
        os.execv("makepkg", {"-si"})
        utils.append_bashrc([[
# nvm config by xlings-xim
[ -s "/usr/share/nvm/init-nvm.sh" ] && \. "/usr/share/nvm/init-nvm.sh"
        ]])
    else
        os.exec("sh " .. pkginfo.install_file)
        utils.append_bashrc([[
# nvm config by xlings-xim
if [ "$NVM_DIR" == "" ]; then export NVM_DIR="$HOME/.nvm"; end
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
        ]])
    end
    return true
end

function uninstall()
    if is_host("windows") then
        -- TODO: uninstall nvm-windows
    elseif utils.os_info().name == "archlinux" then
        os.execv("sudo", {"pacman", "-R", "nvm"})
    else
        local nvm_home = path.join(os.getenv("HOME"), ".nvm")
        os.tryrm(nvm_home)
    end
    return true
end