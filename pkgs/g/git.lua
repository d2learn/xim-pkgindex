package = {
    spec = "1",

    name = "git",
    description = "Git is a free and open source distributed version control system",

    homepage = "https://git-scm.com",
    maintainers = {"GNU"},
    licenses = {"GPL"},

    repo = "https://github.com/git/git",
    docs = "https://git-scm.com/learn",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"git"},
    keywords = {"git"},

    programs = { "git" },

    xpm = {
        windows = {
            deps = { "shortcut-tool" },
            ["latest"] = { ref = "2.51.1" },
            ["2.51.1"] = "XLINGS_RES",
        }
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.system")
import("xim.libxpkg.log")

function install()
    os.tryrm(pkginfo.install_dir())
    local git_dir = pkginfo.install_file()
        :replace(".zip", "")
    os.mv(git_dir, pkginfo.install_dir())
    return true
end

function config()

    xvm.add("git", {
        bindir = path.join(pkginfo.install_dir(), "cmd")
    })

    system.exec(string.format(
        [[shortcut-tool create --name "Git Bash" --target "%s" --icon "%s" --args "%s"]],
        path.join(pkginfo.install_dir(), "git-bash.exe"),
        path.join(pkginfo.install_dir(), "git-bash.exe"),
        "--cd-to-home"
    ))

    return true
end

function uninstall()
    xvm.remove("git")
    system.exec(string.format(
        [[shortcut-tool remove --name "Git Bash"]]
    ))
    return true
end