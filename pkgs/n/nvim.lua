package = {
    spec = "1",
    -- base info
    name = "nvim",
    description = "Vim-fork focused on extensibility and usability",

    contributors = "https://github.com/neovim/neovim/graphs/contributors",
    licenses = {"Apache-2.0"},
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
            -- Runtime deps. nvim prebuilt (nvim-linux-x86_64.tar.gz)
            -- is dynamically linked: INTERP=/lib64/ld-linux-x86-64.so.2,
            -- NEEDED libc.so.6 / libm.so.6 (glibc) and libgcc_s.so.1
            -- (GCC unwind runtime, ships in xim:gcc-runtime). No
            -- libstdc++ — neovim itself is C, not C++.
            deps = {
                runtime = { "xim:glibc@2.39", "xim:gcc-runtime@15.1.0" },
            },
            url_template = "https://github.com/neovim/neovim/releases/download/v{version}/nvim-linux-x86_64.tar.gz",
            ["latest"] = { ref = "0.12.2" },
            ["0.12.2"] = {
                url = "https://github.com/neovim/neovim/releases/download/v0.12.2/nvim-linux-x86_64.tar.gz",
                sha256 = "31cf85945cb600d96cdf69f88bc68bec814acbff50863c5546adef3a1bcef260",
            },
            ["0.11.5"] = {
                url = "https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz",
                sha256 = "b2f91117be5b5ea39edd7297156dc2a4a8df4add6c95a90809a8df19e7ab6f52",
            }
        },
        windows = {
            url_template = "https://github.com/neovim/neovim/releases/download/v{version}/nvim-win64.zip",
            ["latest"] = { ref = "0.12.2" },
            ["0.12.2"] = {
                url = "https://github.com/neovim/neovim/releases/download/v0.12.2/nvim-win64.zip",
                sha256 = "23fe150edbcc976eabe55092e1e9d2e5e237afde69553d170e936f776b405d53",
            },
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

    if os.host() == "windows" then
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
