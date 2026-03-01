package = {
    spec = "1",

    name = "codex",
    description = "Codex CLI from OpenAI",
    homepage = "https://github.com/openai/codex",
    licenses = {"Apache-2.0"},
    repo = "https://github.com/openai/codex",
    docs = "https://github.com/openai/codex#readme",

    type = "package",
    archs = {"x86_64", "aarch64"},
    status = "stable",
    categories = {"ai", "cli", "tools"},
    keywords = {"codex", "openai", "agent", "cli"},

    programs = {"codex"},
    xvm_enable = true,

    xpm = {
        linux = {
            deps = {"nodejs", "npm"},
            ["latest"] = { ref = "0.106.0" },
            ["0.106.0"] = {},
        },
        macosx = {
            deps = {"nodejs", "npm"},
            ["latest"] = { ref = "0.106.0" },
            ["0.106.0"] = {},
        },
        windows = {
            deps = {"nodejs", "npm"},
            ["latest"] = { ref = "0.106.0" },
            ["0.106.0"] = {},
        },
    }
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function installed()
    return os.iorun("xvm list codex")
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())

    local npm_install = string.format(
        [[npm install --prefix "%s" --no-fund --no-audit "@openai/codex@%s"]],
        pkginfo.install_dir(),
        pkginfo.version()
    )
    os.exec(npm_install)

    return true
end

function config()
    local bindir = path.join(pkginfo.install_dir(), "node_modules", ".bin")
    local alias = "codex"

    if is_host("windows") then
        alias = "codex.cmd"
    end

    xvm.add("codex", { bindir = bindir, alias = alias })
    return true
end

function uninstall()
    xvm.remove("codex")
    return true
end
