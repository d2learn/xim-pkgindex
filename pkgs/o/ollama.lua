package = {
    spec = "1",

    name = "ollama",
    description = "Get up and running with large language models locally",
    homepage = "https://ollama.com",
    maintainers = {"Ollama"},
    licenses = {"MIT"},
    repo = "https://github.com/ollama/ollama",
    docs = "https://github.com/ollama/ollama/blob/main/docs/README.md",

    type = "package",
    archs = {"x86_64"},
    status = "stable",
    categories = {"ai", "llm", "tools"},
    keywords = {"ollama", "llama", "llm", "ai", "inference", "gguf"},

    programs = {"ollama"},
    xvm_enable = true,

    -- TODO(zstd): pin to v0.13.x because it is the last release that
    --   ships .tgz / .zip on Linux & Windows. Releases v0.14.0+ switched
    --   to .tar.zst on Linux/Windows, which xlings's is_compressed()
    --   does not auto-extract today (see xlings core/xim/base/utils.lua).
    --   Once xlings learns about .tar.zst (and zstd is wired in) we can
    --   bump this package to track the latest upstream release.
    xpm = {
        linux = {
            -- Runtime deps. ollama prebuilt is dynamically linked
            -- against glibc + GCC C++ runtime: NEEDED libc.so.6 /
            -- libm.so.6 / libdl.so.2 / libpthread.so.0 / librt.so.1 /
            -- libresolv.so.2 (glibc) plus libstdc++.so.6 / libgcc_s.so.1
            -- (xim:gcc-runtime). Don't elide gcc-runtime here — ollama
            -- uses C++ heavily (llama.cpp inference path), so libstdc++
            -- is mandatory.
            deps = {
                runtime = { "xim:glibc@2.39", "xim:gcc-runtime@15.1.0" },
            },
            ["latest"] = { ref = "0.13.3" },
            ["0.13.3"] = {
                url = "https://github.com/ollama/ollama/releases/download/v0.13.3/ollama-linux-amd64.tgz",
                sha256 = "70a3d0f4cccd003641c5531d564a3494ed9a422e397c437d40f802ec1003c6eb",
            },
            ["0.13.0"] = {
                url = "https://github.com/ollama/ollama/releases/download/v0.13.0/ollama-linux-amd64.tgz",
                sha256 = "c5e5b4840008d9c9bf955ec32c32b03afc57c986ac1c382d44c89c9f7dd2cc30",
            },
        },
        macosx = {
            ["latest"] = { ref = "0.13.3" },
            ["0.13.3"] = {
                url = "https://github.com/ollama/ollama/releases/download/v0.13.3/ollama-darwin.tgz",
                sha256 = "f2fd093b044b4951b5a0ec339f9059ba3de95abcf74df2a934c60330b6afc801",
            },
            ["0.13.0"] = {
                url = "https://github.com/ollama/ollama/releases/download/v0.13.0/ollama-darwin.tgz",
                sha256 = "fa4ca04c48453c5ff81447d0630e996ee3e6b6af76a9eba52c69c0732f748161",
            },
        },
        windows = {
            ["latest"] = { ref = "0.13.3" },
            ["0.13.3"] = {
                url = "https://github.com/ollama/ollama/releases/download/v0.13.3/ollama-windows-amd64.zip",
                sha256 = "4a81a0f130bad31962246b31fb053f27e9d2fc8314c0a68c43fd95cf787f17c2",
            },
            ["0.13.0"] = {
                url = "https://github.com/ollama/ollama/releases/download/v0.13.0/ollama-windows-amd64.zip",
                sha256 = "0fc913fc3763b8d2a490f2be90a51d474491ee22ea5a43ff31f1c58301a89656",
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.system")

-- Archive layouts (per-platform, top-level entries):
--   linux .tgz   → bin/ollama          + lib/ollama/...
--   macOS .tgz   → ollama (flat)       + lib*.so / *.dylib at root
--   windows .zip → ollama.exe (flat)   + ollama_runners/... at root
--
-- We extract the archive directly into install_dir rather than relying
-- on xlings's auto-extract-into-runtime-dir, so the install_dir layout
-- is self-contained and not entangled with other packages' extracted
-- artifacts in the shared download dir.
function install()
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())

    local archive = pkginfo.install_file()

    if is_host("windows") then
        system.exec(string.format(
            [[powershell -NoProfile -ExecutionPolicy Bypass -Command ]] ..
            [["Expand-Archive -Path '%s' -DestinationPath '%s' -Force"]],
            archive, pkginfo.install_dir()
        ))
    else
        system.exec(string.format(
            [[tar -xzf "%s" -C "%s"]],
            archive, pkginfo.install_dir()
        ))
    end

    return true
end

function config()
    -- Linux puts the binary at install_dir/bin/ollama; macOS and Windows
    -- archives are flat with the binary at install_dir/ollama(.exe).
    local bindir = pkginfo.install_dir()
    if is_host("linux") then
        bindir = path.join(pkginfo.install_dir(), "bin")
    end
    xvm.add("ollama", { bindir = bindir })
    return true
end

function uninstall()
    xvm.remove("ollama")
    return true
end
