-- only simple package mapping.
-- for complex package/software/config, please use pkgs/xpm

pmwrapper = {
    ["dotnet-9"] = {
        windows = {"winget", "Microsoft.DotNet.SDK.9"},
    },
    ["gcc"] = {
        ubuntu = {"apt", "gcc"},
        archlinux = {"pacman", "gcc"},
    },
    ["g++"] = { ref = "gcc" },
    ["java"] = { ref = "openjdk8" },
    ["java8"] = { ref = "openjdk8" },
    ["jdk8"] = { ref = "openjdk8" },
    ["openjdk"] = { ref = "openjdk8" },
    ["openjdk8"] = {
        windows = {"winget", "AdoptOpenJDK.OpenJDK.8"},
        ubuntu = {"apt", "openjdk-8-jdk"},
        archlinux = {"pacman", "jdk8-openjdk"},
    },
    ["python"] = {
        windows = {"winget", "Python.Python.3.13"},
        ubuntu = {"apt", "python3"},
        archlinux = {"pacman", "python"},
    },
    ["vim"] = {
        windows = {"winget", "vim.vim"},
        ubuntu = {"apt", "vim"},
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