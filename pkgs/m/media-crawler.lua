package = {
    spec = "1",

    name = "media-crawler",
    description = "Multi-platform social media crawler (XHS, Douyin, Kuaishou, Bilibili, Weibo, Tieba, Zhihu) using Playwright",

    authors = {"NanmiCoder"},
    maintainers = {"NanmiCoder"},
    licenses = {"MIT"},
    repo = "https://github.com/NanmiCoder/MediaCrawler",
    homepage = "https://github.com/NanmiCoder/MediaCrawler",

    type = "package",
    archs = {"x86_64", "arm64"},
    status = "dev",
    categories = {"tools", "crawler", "data"},
    keywords = {"crawler", "scraper", "social-media", "xiaohongshu", "douyin", "bilibili", "weibo", "playwright"},

    programs = {"media-crawler"},
    xvm_enable = true,

    -- Source archive from GitHub (pinned to commit).
    -- Requires Python >= 3.11 and Node.js >= 16 at runtime.
    xpm = {
        linux = {
            deps = {"python", "uv"},
            ["latest"] = { ref = "2026.4.30" },
            ["2026.4.30"] = {
                url = "https://github.com/NanmiCoder/MediaCrawler/archive/f328ee35b55e25e8aaeb9c847fe8b622e3f3447f.tar.gz",
                sha256 = "f11b00a9425cc89488054a395e27fc86d846372854b2d5d684cec6b5ce6576b2",
            },
        },
        macosx = {
            ["latest"] = { ref = "2026.4.30" },
            ["2026.4.30"] = {
                url = "https://github.com/NanmiCoder/MediaCrawler/archive/f328ee35b55e25e8aaeb9c847fe8b622e3f3447f.tar.gz",
                sha256 = "f11b00a9425cc89488054a395e27fc86d846372854b2d5d684cec6b5ce6576b2",
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.system")

function __source_dir()
    local archive = pkginfo.install_file()
    local dir = path.directory(archive)
    return path.join(dir, "MediaCrawler-f328ee35b55e25e8aaeb9c847fe8b622e3f3447f")
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.cp(__source_dir(), pkginfo.install_dir())

    -- Use uv to create venv and sync dependencies
    system.exec(string.format([[cd "%s" && uv venv && uv sync]], pkginfo.install_dir()))

    -- Install playwright chromium browser
    system.exec(string.format([[cd "%s" && uv run playwright install chromium]], pkginfo.install_dir()))

    -- Create launcher script
    local bindir = path.join(pkginfo.install_dir(), "bin")
    os.mkdir(bindir)
    local launcher = path.join(bindir, "media-crawler")
    io.writefile(launcher, string.format([[#!/bin/bash
cd "%s"
exec uv run main.py "$@"
]], pkginfo.install_dir()))
    os.exec(string.format([[chmod +x "%s"]], launcher))

    return true
end

function config()
    xvm.add("media-crawler", {
        bindir = path.join(pkginfo.install_dir(), "bin"),
    })
    return true
end

function uninstall()
    xvm.remove("media-crawler")
    return true
end
