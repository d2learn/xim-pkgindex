package = {
    spec = "1",

    name = "uv",
    description = "An extremely fast Python package and project manager (Astral)",
    homepage = "https://docs.astral.sh/uv",
    maintainers = {"Astral"},
    licenses = {"MIT", "Apache-2.0"},
    repo = "https://github.com/astral-sh/uv",
    docs = "https://docs.astral.sh/uv",

    type = "package",
    archs = {"x86_64", "aarch64"},
    status = "stable",
    categories = {"python", "package-manager", "tools"},
    keywords = {"python", "uv", "pip", "venv", "poetry", "astral"},

    programs = {"uv", "uvx"},
    xvm_enable = true,

    xpm = {
        linux = {
            -- Runtime deps. uv-x86_64-unknown-linux-gnu prebuilt is
            -- dynamically linked: NEEDED libc.so.6 / libpthread.so.0
            -- (glibc) plus libgcc_s.so.1 (xim:gcc-runtime, for Rust
            -- panic-unwind tables). Rust statically links libstdc++
            -- so libstdc++ is not needed.
            deps = {
                runtime = { "xim:glibc@2.39", "xim:gcc-runtime@15.1.0" },
            },
            -- url_template: opt-in marker for the in-repo version checker
            -- (.github/scripts/version-check.py). The placeholder
            -- {version} is substituted with the upstream GitHub release
            -- version when proposing a bump. xlings install does not read
            -- this field; it stays on the explicit per-version `url`.
            -- See docs/spec/url-template.md.
            url_template = "https://github.com/astral-sh/uv/releases/download/{version}/uv-x86_64-unknown-linux-gnu.tar.gz",
            ["latest"] = { ref = "0.11.7" },
            ["0.11.7"] = {
                url = "https://github.com/astral-sh/uv/releases/download/0.11.7/uv-x86_64-unknown-linux-gnu.tar.gz",
                sha256 = "6681d691eb7f9c00ac6a3af54252f7ab29ae72f0c8f95bdc7f9d1401c23ea868",
            },
        },
        -- macosx: the upstream ships separate x86_64 and aarch64 builds.
        -- Modern Macs (and the GitHub macos-latest runner) are aarch64,
        -- which is what we ship. Intel-Mac users would need a separate
        -- per-arch dispatch (xpm doesn't natively branch on arch yet).
        macosx = {
            url_template = "https://github.com/astral-sh/uv/releases/download/{version}/uv-aarch64-apple-darwin.tar.gz",
            ["latest"] = { ref = "0.11.7" },
            ["0.11.7"] = {
                url = "https://github.com/astral-sh/uv/releases/download/0.11.7/uv-aarch64-apple-darwin.tar.gz",
                sha256 = "66e37d91f839e12481d7b932a1eccbfe732560f42c1cfb89faddfa2454534ba8",
            },
        },
        windows = {
            url_template = "https://github.com/astral-sh/uv/releases/download/{version}/uv-x86_64-pc-windows-msvc.zip",
            ["latest"] = { ref = "0.11.7" },
            ["0.11.7"] = {
                url = "https://github.com/astral-sh/uv/releases/download/0.11.7/uv-x86_64-pc-windows-msvc.zip",
                sha256 = "fe0c7815acf4fc45f8a5eff58ed3cf7ae2e15c3cf1dceadbd10c816ec1690cc1",
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

-- Archive layouts:
--   Linux/macOS .tar.gz extracts into a single dir named after the
--     archive (e.g. `uv-x86_64-unknown-linux-gnu/`) containing `uv`
--     and `uvx` at its top level.
--   Windows .zip drops `uv.exe`, `uvx.exe`, `uvw.exe` directly into
--     the extraction directory (no enclosing folder).
--
-- The download dir is the directory containing pkginfo.install_file(),
-- and the extracted folder is named the same as the tarball without
-- its compression suffix. Deriving paths from install_file() avoids
-- assuming xlings's cwd matches the extraction location, which has
-- proven flaky across hosts.
function install()
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())

    local download_dir = path.directory(pkginfo.install_file())

    if is_host("windows") then
        for _, exe in ipairs({"uv.exe", "uvx.exe"}) do
            os.mv(path.join(download_dir, exe), path.join(pkginfo.install_dir(), exe))
        end
    else
        local extracted = pkginfo.install_file():replace(".tar.gz", "")
        for _, exe in ipairs({"uv", "uvx"}) do
            os.mv(path.join(extracted, exe), path.join(pkginfo.install_dir(), exe))
        end
        os.tryrm(extracted)
    end

    return true
end

function config()
    local bindir = pkginfo.install_dir()
    xvm.add("uv", { bindir = bindir })
    xvm.add("uvx", { bindir = bindir, binding = "uv@" .. pkginfo.version() })
    return true
end

function uninstall()
    xvm.remove("uv")
    xvm.remove("uvx")
    return true
end
