-- only simple package mapping.
-- for complex package/software/config, please use pkgs/xpm

pmwrapper = {
    ["dotnet-9"] = {
        windows = {"winget", "microsoft.dotnet.sdk.9"},
    },
    ["gcc"] = {
        ubuntu = {"apt", "gcc"},
        archlinux = {"pacman", "gcc"},
    },
    ["g++"] = { ref = "gcc" },
    ["java"] = { ref = "openjdk8" },
    ["java8"] = { ref = "openjdk8" },
    ["jdk8"] = { ref = "openjdk8" },
    ["mdbook"] = {
        archlinux = {"pacman", "mdbook"}
    },
    ["openjdk"] = { ref = "openjdk8" },
    ["openjdk8"] = {
        windows = {"winget", "AdoptOpenJDK.OpenJDK.8"},
        ubuntu = {"apt", "openjdk-8-jdk"},
        archlinux = {"pacman", "jdk8-openjdk"},
    },
    ["python"] = {
        windows = {"winget", "python.python.3.9"},
        ubuntu = {"apt", "python3"},
        archlinux = {"pacman", "python"},
    },
    ["rust"] = {
        archlinux = {"pacman", "rustup"}
    },
    ["vim"] = {
        windows = {"winget", "vim.vim"},
        ubuntu = {"apt", "vim"},
        archlinux = {"pacman", "vim"}
    },
    ["visual-studio"] = { ref = "vs2022" },
    ["vs2022"] = {
        windows = {"winget", "Microsoft.VisualStudio.2022.Community"},
    },
    ["vscode"] = {
        windows = {"winget", "Microsoft.VisualStudioCode"},
        archlinux = {"pacman", "code"},
    },
    ["wsl"] = {
        windows = {"winget", "Microsoft.WSL"},
    },
}