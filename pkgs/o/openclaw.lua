package = {
    spec = "1",

    name = "openclaw",
    description = "OpenClaw CLI",
    homepage = "https://github.com/openclaw/openclaw",
    licenses = {"MIT"},
    repo = "https://github.com/openclaw/openclaw",
    docs = "https://github.com/openclaw/openclaw#readme",

    type = "package",
    archs = {"x86_64", "aarch64"},
    status = "stable",
    categories = {"ai", "cli", "tools"},
    keywords = {"openclaw", "agent", "cli"},

    programs = {"openclaw"},
    xvm_enable = true,

    xpm = {
        linux = {
            deps = {"nodejs", "npm"},
            ["latest"] = { ref = "2026.2.26" },
            ["2026.2.26"] = {},
        },
        macosx = {
            deps = {"nodejs", "npm"},
            ["latest"] = { ref = "2026.2.26" },
            ["2026.2.26"] = {},
        },
        windows = {
            deps = {"nodejs", "npm"},
            ["latest"] = { ref = "2026.2.26" },
            ["2026.2.26"] = {},
        },
    }
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function installed()
    return os.iorun("xvm list openclaw")
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())

    local npm_install = string.format(
        [[npm install --prefix "%s" --no-fund --no-audit "openclaw@%s"]],
        pkginfo.install_dir(),
        pkginfo.version()
    )
    os.exec(npm_install)

    return true
end

function config()
    local bindir = path.join(pkginfo.install_dir(), "node_modules", ".bin")
    local alias = "openclaw"

    if is_host("windows") then
        alias = "openclaw.cmd"
    end

    xvm.add("openclaw", { bindir = bindir, alias = alias })
    return true
end

function uninstall()
    xvm.remove("openclaw")
    return true
end
