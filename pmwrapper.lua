-- only simple package mapping.
-- for complex package/software/config, please use pkgs/xpm

pmwrapper = {
    ["java"] = {
        windows = {"winget", "AdoptOpenJDK.OpenJDK.8"},
        ubuntu = {"apt", "openjdk-8-jdk"},
        archlinux = {"pacman", "jdk8-openjdk"},
    },
    ["vim"] = {
        winget = {"winget", "vim.vim"},
        ubuntu = {"apt", "vim"},
    },
    ["visual-studio"] = {
        windows = {"winget", "Microsoft.VisualStudio.2022.Community"},
    },
    ["vscode"] = {
        windows = {"winget", "Microsoft.VisualStudioCode"},
        archlinux = {"pacman", "code"},
    },
    ["vs-build-tools"] = {
        windows = {"winget", "Microsoft.VisualStudio.2022.BuildTools"},
    },
}