package = {
    spec = "1",

    name = "claude-code",
    description = "Claude Code CLI from Anthropic",
    homepage = "https://github.com/anthropics/claude-code",
    licenses = {"MIT"},
    repo = "https://github.com/anthropics/claude-code",
    docs = "https://docs.anthropic.com/en/docs/claude-code/overview",

    type = "package",
    archs = {"x86_64", "aarch64"},
    status = "stable",
    categories = {"ai", "cli", "tools"},
    keywords = {"claude", "anthropic", "agent", "cli"},

    programs = {"claude"},
    xvm_enable = true,

    xpm = {
        linux = {
            deps = {"nodejs", "npm"},
            ["latest"] = { ref = "2.1.63" },
            ["2.1.63"] = {},
        },
        macosx = {
            deps = {"nodejs", "npm"},
            ["latest"] = { ref = "2.1.63" },
            ["2.1.63"] = {},
        },
        windows = {
            deps = {"nodejs", "npm"},
            ["latest"] = { ref = "2.1.63" },
            ["2.1.63"] = {},
        },
    }
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function installed()
    return os.iorun("xvm list claude")
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())

    local npm_install = string.format(
        [[npm install --prefix "%s" --no-fund --no-audit "@anthropic-ai/claude-code@%s"]],
        pkginfo.install_dir(),
        pkginfo.version()
    )
    os.exec(npm_install)

    return true
end

function config()
    local bindir = path.join(pkginfo.install_dir(), "node_modules", ".bin")
    local alias = "claude"

    if is_host("windows") then
        alias = "claude.cmd"
    end

    xvm.add("claude", { bindir = bindir, alias = alias })
    return true
end

function uninstall()
    xvm.remove("claude")
    return true
end
