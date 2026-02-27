package = {
    spec = "1",
    homepage = "https://llvm.org",

    name = "llvm",
    description = "LLVM compiler infrastructure and toolchain",
    maintainers = {"LLVM Project"},
    licenses = {"Apache-2.0 WITH LLVM-exception"},
    repo = "https://github.com/llvm/llvm-project",
    docs = "https://llvm.org/docs/",

    type = "package",
    archs = {"arm64"},
    status = "stable",
    categories = {"compiler", "toolchain", "llvm"},
    keywords = {"llvm", "clang", "lld", "compiler", "linker"},

    xvm_enable = true,

    xpm = {
        macosx = {
            ["latest"] = { ref = "20.1.7" },
            ["20.1.7"] = {
                url = "https://gitcode.com/xlings-res/llvm/releases/download/20.1.7/LLVM-20.1.7-macOS-ARM64.tar.xz",
                sha256 = nil,
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")

local alias_apps = {
    {name = "cc", alias = "clang"},
    {name = "c++", alias = "clang++"},
    {name = "ar", alias = "llvm-ar"},
    {name = "ranlib", alias = "llvm-ranlib"},
    {name = "strip", alias = "llvm-strip"},
    {name = "nm", alias = "llvm-nm"},
}

local function is_registerable_bin(pathname)
    local name = path.filename(pathname)
    if name == nil or name == "" then
        return false
    end
    if name:endswith(".cfg") then
        return false
    end
    return os.isfile(pathname)
end

local function collect_bin_apps(bindir)
    local apps = {}
    for _, filepath in ipairs(os.files(path.join(bindir, "*"))) do
        if is_registerable_bin(filepath) then
            table.insert(apps, path.filename(filepath))
        end
    end
    table.sort(apps)
    return apps
end

function install()
    local llvmdir = pkginfo.install_file()
        :replace(".tar.xz", "")
        :replace(".tar.gz", "")
        :replace(".zip", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(llvmdir, pkginfo.install_dir())

    -- Make packaged clang/clang++ usable out-of-box on macOS.
    local libdir = path.join(pkginfo.install_dir(), "lib")
    local cxxinc = path.join(pkginfo.install_dir(), "include", "c++", "v1")
    local sdkroot = nil

    if os.host() == "macosx" then
        local env_sdkroot = os.getenv("SDKROOT")
        if env_sdkroot and env_sdkroot ~= "" and os.isdir(env_sdkroot) then
            sdkroot = env_sdkroot
        else
            local candidates = {
                "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk",
                "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk",
            }
            for _, cand in ipairs(candidates) do
                if os.isdir(cand) then
                    sdkroot = cand
                    break
                end
            end
        end
    end

    local clang_cfg = ""
    local clangxx_cfg = "-isystem" .. cxxinc .. "\n"
        -- runtime conflict with system libc++
        --.. "-L" .. libdir .. "\n"
        --.. "-Wl,-rpath," .. libdir .. "\n"
        --.. "-lc++\n"
        --.. "-lc++abi\n"
        --.. "-lunwind\n"

    if sdkroot and sdkroot ~= "" then
        clang_cfg = "--sysroot=" .. sdkroot .. "\n"
        clangxx_cfg = "--sysroot=" .. sdkroot .. "\n" .. clangxx_cfg
    else
        log.warn("macOS SDK path not detected; clang may need manual --sysroot")
    end

    io.writefile(path.join(pkginfo.install_dir(), "bin", "clang.cfg"), clang_cfg)
    io.writefile(path.join(pkginfo.install_dir(), "bin", "clang-20.cfg"), clang_cfg)
    io.writefile(path.join(pkginfo.install_dir(), "bin", "clang++.cfg"), clangxx_cfg)

    return true
end

function config()
    local bindir = path.join(pkginfo.install_dir(), "bin")
    local binding = package.name .. "@" .. pkginfo.version()
    local related_apps = collect_bin_apps(bindir)

    xvm.add(package.name)

    for _, app in ipairs(related_apps) do
        xvm.add(app, {
            bindir = bindir,
            binding = binding,
        })
    end

    for _, app in ipairs(alias_apps) do
        if os.isfile(path.join(bindir, app.alias)) then
            xvm.add(app.name, {
                bindir = bindir,
                alias = app.alias,
                binding = binding,
            })
        else
            log.warn("skip xvm add alias (not found): " .. app.name .. " -> " .. app.alias)
        end
    end

    return true
end

function uninstall()
    local bindir = path.join(pkginfo.install_dir(), "bin")
    local related_apps = collect_bin_apps(bindir)

    xvm.remove(package.name)

    for _, app in ipairs(related_apps) do
        xvm.remove(app)
    end

    for _, app in ipairs(alias_apps) do
        xvm.remove(app.name)
    end

    return true
end
