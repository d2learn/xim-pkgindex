package = {
    -- base info
    name = "nvim",
    description = "Vim-fork focused on extensibility and usability",

    contributors = "https://github.com/neovim/neovim/graphs/contributors",
    licenses = "Apache 2.0",
    repo = "https://github.com/neovim/neovim",
    docs = "https://neovim.io/doc",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"vim", "editor"},
    keywords = {"vim", "editor"},

    programs = { "nvim", "neovim" },

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            ["latest"] = { ref = "0.11.5" },
            ["0.11.5"] = {
                url = "https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz",
                sha256 = "b2f91117be5b5ea39edd7297156dc2a4a8df4add6c95a90809a8df19e7ab6f52",
            }
        },
        windows = {
            ["latest"] = { ref = "0.11.5" },
            ["0.11.5"] = {
                url = "https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-win64.zip",
                sha256 = "718e731326e7759cf17bbbb33f38975707a2ac85642614686b818ef5fde38f48",
            }
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()

    local nvim_dir = "nvim-linux-x86_64"

    if is_host("windows") then
        nvim_dir = "nvim-win64"
    end

    os.tryrm(pkginfo.install_dir())
    os.mv(nvim_dir, pkginfo.install_dir())
    return true
end

function config()
    xvm.add("nvim", { bindir = path.join(pkginfo.install_dir(), "bin") })
    xvm.add("neovim", { alias = "nvim" })
    return true
end

function uninstall()
    xvm.remove("nvim")
    xvm.remove("neovim")
    return true
end
