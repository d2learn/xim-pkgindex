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

-- 结构说明（基于 npm 包元数据 + 本地安装校验）:
--   1) 包自身入口由 package.json 的 bin.claude = "cli.js" 定义
--   2) 安装后主入口位于: <install>/node_modules/@anthropic-ai/claude-code/cli.js
--   3) npm .bin 包装脚本在不同 OS 的形态可能不同（如 .cmd/.ps1），这里不依赖它
function __claude_cli()
    return path.join(pkginfo.install_dir(), "node_modules", "@anthropic-ai", "claude-code", "cli.js")
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

    if not os.isfile(__claude_cli()) then
        raise("claude cli.js not found after npm install")
    end

    return true
end

function config()
    xvm.add("claude", {
        alias = string.format([[node "%s"]], __claude_cli()),
        envs = {
            CLAUDE_CONFIG_DIR = path.join(pkginfo.install_dir(), "config"),
        }
    })
    return true
end

function uninstall()
    xvm.remove("claude")
    return true
end
