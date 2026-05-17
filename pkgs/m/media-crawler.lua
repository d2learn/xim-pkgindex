package = {
    spec = "1",

    name = "media-crawler",
    description = "Multi-platform social media scraper (XHS, Douyin, Kuaishou, Bilibili, Weibo, Tieba, Zhihu) using Playwright",

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
            deps = {"python"},
            ["latest"] = { ref = "2026.4.30" },
            ["2026.4.30"] = {
                url = "https://github.com/NanmiCoder/MediaCrawler/archive/f328ee35b55e25e8aaeb9c847fe8b622e3f3447f.tar.gz",
                sha256 = "f11b00a9425cc89488054a395e27fc86d846372854b2d5d684cec6b5ce6576b2",
            },
        },
        macosx = {
            deps = {"python"},
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
    -- GitHub archive extracts to <repo>-<full_sha>/
    return path.join(dir, "MediaCrawler-f328ee35b55e25e8aaeb9c847fe8b622e3f3447f")
end

function install()
    os.tryrm(pkginfo.install_dir())

    -- Create venv and install dependencies
    system.exec(string.format([[python3 -m venv "%s"]], pkginfo.install_dir()))
    local venv_pip = path.join(pkginfo.install_dir(), "bin", "pip")
    if os.host() == "windows" then
        venv_pip = path.join(pkginfo.install_dir(), "Scripts", "pip.exe")
    end

    system.exec(string.format([["%s" install --upgrade pip]], venv_pip))
    system.exec(string.format([["%s" install -r "%s/requirements.txt"]], venv_pip, __source_dir()))

    -- Copy source into install dir
    os.cp(path.join(__source_dir(), "*"), path.join(pkginfo.install_dir(), "src"))

    -- Install playwright browsers
    local venv_playwright = path.join(pkginfo.install_dir(), "bin", "playwright")
    system.exec(string.format([["%s" install chromium]], venv_playwright))

    -- Create launcher script
    local launcher = path.join(pkginfo.install_dir(), "bin", "media-crawler")
    local venv_python = path.join(pkginfo.install_dir(), "bin", "python")
    local src_dir = path.join(pkginfo.install_dir(), "src")
    io.writefile(launcher, string.format([[#!/bin/bash
cd "%s"
exec "%s" main.py "$@"
]], src_dir, venv_python))
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
