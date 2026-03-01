package = {
    spec = "1",

    name = "github-gh",
    description = "GitHub's official command line tool",

    homepage = "https://cli.github.com",
    maintainers = {"GitHub"},
    licenses = {"MIT"},
    repo = "https://github.com/cli/cli",
    docs = "https://cli.github.com/manual",

    -- xim pkg info
    type = "package",
    archs = {"x86_64", "aarch64"},
    status = "stable",
    categories = {"git", "github", "cli", "tools"},
    keywords = {"github", "gh", "cli", "git", "pull-request", "issue"},

    programs = {"gh", "github-gh"},
    xvm_enable = true,

    xpm = {
        linux = {
            ["latest"] = { ref = "2.86.0" },
            ["2.86.0"] = {
                url = "https://github.com/cli/cli/releases/download/v2.86.0/gh_2.86.0_linux_amd64.tar.gz",
                sha256 = nil,
            },
            -- ["2.86.0"] = "XLINGS_RES",
        },
        macosx = {
            ["latest"] = { ref = "2.86.0" },
            ["2.86.0"] = {
                url = "https://github.com/cli/cli/releases/download/v2.86.0/gh_2.86.0_macOS_amd64.zip",
                sha256 = nil,
            },
            -- ["2.86.0"] = "XLINGS_RES",
        },
        windows = {
            ["latest"] = { ref = "2.86.0" },
            ["2.86.0"] = {
                url = "https://github.com/cli/cli/releases/download/v2.86.0/gh_2.86.0_windows_amd64.zip",
                sha256 = nil,
            },
            -- ["2.86.0"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function installed()
    return os.iorun("gh --version")
end

function install()
    os.tryrm(pkginfo.install_dir())

    local gh_dir = string.format("gh_%s_linux_amd64", pkginfo.version())

    if os.host() == "macosx" then
        gh_dir = string.format("gh_%s_macOS_amd64", pkginfo.version())
    elseif os.host() == "windows" then
        gh_dir = string.format("gh_%s_windows_amd64", pkginfo.version())
    end

    os.mv(gh_dir, pkginfo.install_dir())
    return true
end

function config()
    local bindir = path.join(pkginfo.install_dir(), "bin")
    xvm.add("gh", { bindir = bindir })
    xvm.add("github-gh", { bindir = bindir, alias = "gh" })
    return true
end

function uninstall()
    xvm.remove("gh")
    xvm.remove("github-gh")
    return true
end
