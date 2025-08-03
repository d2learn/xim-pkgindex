-- only simple package mapping.
-- for complex package/software/config, please use pkgs/xpm

pmwrapper = {
    ["bzip2"] = {
        ubuntu = {"apt", "bzip2"},
        archlinux = {"pacman", "bzip2"},
    },
    ["cmake"] = {
        ubuntu = {"apt", "cmake"},
        archlinux = {"pacman", "cmake"},
    },
    ["code-oss"] = {
        archlinux = {"pacman", "code"},
        manjaro = {"pacman", "code"},
    },
    ["dotnet-9"] = {
        windows = {"winget", "Microsoft.DotNet.SDK.9"},
    },
    ["fzf"] = {
        windows = {"winget", "fzf"},
        ubuntu = {"apt", "fzf"},
        archlinux = {"pacman", "fzf"},
        manjaro = {"pacman", "fzf"},
    },
    ["gcc"] = {
        ubuntu = {"apt", "gcc"},
        archlinux = {"pacman", "gcc"},
        manjaro = {"pacman", "gcc"},
    },
    ["gzip"] = {
        ubuntu = {"apt", "gzip"},
        archlinux = {"pacman", "gzip"},
    },
    ["g++"] = { ref = "gcc" },
    ["java"] = { ref = "openjdk8" },
    ["java8"] = { ref = "openjdk8" },
    ["jdk8"] = { ref = "openjdk8" },
    ["mdbook"] = {
        archlinux = {"pacman", "mdbook"},
        manjaro = {"pacman", "mdbook"},
    },
    ["make"] = {
        ubuntu = {"apt", "make"},
        archlinux = {"pacman", "make"},
        manjaro = {"pacman", "make"},
    },
    ["nodejs"] = {
        archlinux = {"pacman", "nodejs"},
        manjaro = {"pacman", "nodejs"},
    },
    ["nvm"] = {
        archlinux = {"aur", "nvm"},
        manjaro = {"aur", "nvm"},
    },
    ["openjdk"] = { ref = "openjdk8" },
    ["openjdk8"] = {
        windows = {"winget", "AdoptOpenJDK.OpenJDK.8"},
        ubuntu = {"apt", "openjdk-8-jdk"},
        archlinux = {"pacman", "jdk8-openjdk"},
        manjaro = {"pacman", "jdk8-openjdk"},
    },
    ["pnpm"] = {
        archlinux = {"pacman", "pnpm"},
        manjaro = {"pacman", "pnpm"},
    },
    ["project-graph"] = {
        archlinux = {"aur", "project-graph-bin"},
        manjaro = {"aur", "project-graph-bin"},
    },
    ["project-graph-nightly"] = {
        archlinux = {"aur", "project-graph-nightly-bin"},
        manjaro = {"aur", "project-graph-nightly-bin"},
    },
    ["python"] = {
        windows = {"winget", "Python.Python.3.13"},
        ubuntu = {"apt", "python3"},
        archlinux = {"pacman", "python"},
        manjaro = {"pacman", "python"},
    },
    ["qq"] = {
        archlinux = {"aur", "linuxqq-nt-bwrap"},
        manjaro = {"aur", "linuxqq-nt-bwrap"},
    },
    ["rust"] = {
        archlinux = {"pacman", "rustup"},
        manjaro = {"pacman", "rustup"},
    },
    ["xz"] = {
        ubuntu = {"apt", "xz-utils"},
        archlinux = {"pacman", "xz"},
    },
    ["vim"] = {
        windows = {"winget", "vim.vim"},
        ubuntu = {"apt", "vim"},
        archlinux = {"pacman", "vim"},
        manjaro = {"pacman", "vim"},
    },
    ["visual-studio"] = { ref = "vs2022" },
    ["vs2022"] = {
        windows = {"winget", "Microsoft.VisualStudio.2022.Community"},
    },
    ["vscode"] = {
        windows = {"winget", "Microsoft.VisualStudioCode"},
        archlinux = {"aur", "visual-studio-code-bin"},
        manjaro = {"aur", "visual-studio-code-bin"},
    },
    ["vscodium"] = {
        archlinux = {"aur", "vscodium-electron-bin"},
        manjaro = {"aur", "vscodium-electron-bin"},
    },
    ["webkit2gtk"] = {
        ubuntu = {"apt", "libwebkit2gtk-4.0-37"},
        archlinux = {"pacman", "webkit2gtk"},
        manjaro = {"pacman", "webkit2gtk"},
    },
    ["wechat"] = {
        archlinux = {"aur", "wechat-universal-bwrap"},
        manjaro = {"aur", "wechat-universal-bwrap"},
    },
    ["wsl"] = {
        windows = {"winget", "Microsoft.WSL"},
    },
}
