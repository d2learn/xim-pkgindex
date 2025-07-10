-- https://github.com/Homebrew/install

package = {
    -- base info
    homepage = "https://brew.sh",

    name = "brew",
    description = "Homebrew: The Missing Package Manager for macOS (or Linux)",

    authors = "Mike McQuaid",
    licenses = "BSD-2-Clause",
    repo = "https://github.com/Homebrew/brew",

    -- xim pkg info
    status = "stable", -- dev, stable, deprecated
    categories = {"package-manager", "macos", "ruby"},
    keywords = {"package", "macos", "ruby"},

    xpm = {
        linux = {
            ["latest"] = {
                url = "https://github.com/Homebrew/brew.git",
                sha256 = nil,
            },
        },
        macosx = {
            ["latest"] = {
                url = "https://github.com/Homebrew/brew.git",
                sha256 = nil,
            },
        },
    },
}

import("xim.libxpkg.log")
import("xim.libxpkg.system")
import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    local homebrewdir = path.join(pkginfo.install_dir(), "homebrew")

    os.tryrm(homebrewdir)
    os.mv("brew", homebrewdir)

    local tmp_file = "brew_update.sh"
    local update_script = string.format([[
#!/bin/bash
eval "$(%s/bin/brew shellenv)"
brew update --force --quiet
chmod -R go-w "$(brew --prefix)/share/zsh"
]], homebrewdir)

    io.writefile(tmp_file, update_script)
    os.exec("bash " .. tmp_file)

    os.rm(tmp_file)

    return true
end

function config()
    local homebrewdir = path.join(pkginfo.install_dir(), "homebrew")

    local brewbindir = path.join(homebrewdir, "bin")

    system.unix_api().append_to_shell_profile({
        posix = string.format([[test -f %s/brew && eval "$(%s/brew shellenv)"]], brewbindir, brewbindir),
        fish  = string.format([[test -f %s/brew; and eval (%s/brew shellenv)]], brewbindir, brewbindir),
    })

    xvm.add("brew", { bindir = brewbindir })

    return true
end

function uninstall()
    --local homebrewdir = path.join(pkginfo.install_dir(), "homebrew")
    --os.exec("curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh -o uninstall.sh")
    --os.setenv("NONINTERACTIVE", "1")
    --os.exec([[/bin/bash uninstall.sh --path ]] .. homebrewdir)
    --os.exec([[/bin/bash uninstall.sh]])
    --os.rm("uninstall.sh")

    local homedir = os.getenv("HOME")

    -- Remove Homebrew directories
    os.tryrm(path.join(homedir, ".cache/Homebrew"))

    xvm.remove("brew")

    return true
end