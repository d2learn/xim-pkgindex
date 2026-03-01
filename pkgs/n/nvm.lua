package = {
    spec = "1",
    name = "nvm",
    description = "Node Version Manager",
    homepage = "https://github.com/nvm-sh/nvm",
    authors = {"Tim Caswell"},
    maintainers = {"https://github.com/nvm-sh/nvm?tab=readme-ov-file#maintainers"},
    licenses = {"MIT"},
    type = "config",
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
        linux = {
            ["latest"] = { ref = "0.39.0"},
            ["0.39.0"] = {
                url = "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh",
                sha256 = nil,
            },
        },
    },
}

import("xim.base.utils")
import("xim.libxpkg.pkginfo")

local function iorun(cmd)
    local f = io.popen(cmd)
    if not f then return "" end
    local output = f:read("*a")
    f:close()
    return output or ""
end

function installed()
    return iorun("nvm --version")
end

function install()
    if os.host() == "windows" then
        os.execute(pkginfo.install_file() .. " /SILENT")

        local nvm_home = "C:\\Users\\" .. os.getenv("USERNAME") .. "\\AppData\\Roaming\\nvm"
        local node_home = "C:\\Program Files\\nodejs"

        -- TODO: os.setenv not available in xpkg runtime, using setx as workaround
        os.execute(string.format('setx NVM_HOME "%s"', nvm_home))
        os.execute(string.format('setx NVM_SYMLINK "%s"', node_home))

        -- TODO: os.addenv not available in xpkg runtime, using setx to prepend to PATH as workaround
        os.execute(string.format('setx PATH "%s;%s;%%PATH%%"', nvm_home, node_home))
    else
        os.execute("sh " .. pkginfo.install_file())
        utils.append_bashrc([[
# nvm config by xlings-xim
if [ "$NVM_DIR" == "" ]; then export NVM_DIR="$HOME/.nvm"; fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
        ]])
    end
    return true
end

function uninstall()
    if os.host() == "windows" then
        -- TODO: uninstall nvm-windows
    else
        local nvm_home = path.join(os.getenv("HOME"), ".nvm")
        os.tryrm(nvm_home)
    end
    return true
end