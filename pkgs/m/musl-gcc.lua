package = {
    spec = "1",
    -- base info
    name = "musl-gcc",
    description = "GCC, the GNU Compiler Collection ( prebuild with musl )",

    authors = {"GNU"},
    licenses = {"GPL"},
    repo = "https://github.com/gcc-mirror/gcc",
    docs = "https://gcc.gnu.org/wiki",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"compiler", "gnu", "language"},
    keywords = {"compiler", "gnu", "gcc", "language", "c", "c++"},

    programs = {
        -- "musl-gcc-static", "musl-g++-static",
        "musl-gcc", "musl-g++", "musl-c++", "musl-cpp",
        "musl-addr2line", "musl-ar", "musl-as", "musl-ld", "musl-nm",
        "musl-objcopy", "musl-objdump", "musl-ranlib", "musl-readelf",
        "musl-size", "musl-strings", "musl-strip",
    },

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            -- toolchain build based on musl-gcc-static
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = "XLINGS_RES", -- deps musl-gcc
            ["13.3.0"] = "XLINGS_RES",
            ["11.5.0"] = "XLINGS_RES",
            ["9.4.0"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")
import("lib.detect.find_tool")

local toolchain_dynamic_bins = {
    "x86_64-linux-musl-addr2line",
    "x86_64-linux-musl-ar",
    "x86_64-linux-musl-as",
    "x86_64-linux-musl-c++filt",
    "x86_64-linux-musl-elfedit",
    "x86_64-linux-musl-gprof",
    "x86_64-linux-musl-ld",
    "x86_64-linux-musl-ld.bfd",
    "x86_64-linux-musl-nm",
    "x86_64-linux-musl-objcopy",
    "x86_64-linux-musl-objdump",
    "x86_64-linux-musl-ranlib",
    "x86_64-linux-musl-readelf",
    "x86_64-linux-musl-size",
    "x86_64-linux-musl-strings",
    "x86_64-linux-musl-strip",
    -- target-prefixed copies
    "ar", "as", "ld", "ld.bfd", "nm",
    "objcopy", "objdump", "ranlib", "readelf", "strip",
}

local function __patch_toolchain_dynamic_bins()
    local patchelf = find_tool("patchelf")
    if not patchelf then
        raise("patchelf not found: musl-gcc runtime relocation requires patchelf")
    end

    local install_dir = pkginfo.install_dir()
    local musl_lib_dir = path.join(install_dir, "x86_64-linux-musl", "lib")
    local musl_loader = path.join(musl_lib_dir, "libc.so")

    if not os.isfile(musl_loader) then
        raise("musl loader not found: " .. musl_loader)
    end

    local bindirs = {
        path.join(install_dir, "bin"),
        path.join(install_dir, "x86_64-linux-musl", "bin"),
    }

    local patched = 0
    for _, bindir in ipairs(bindirs) do
        if os.isdir(bindir) then
            for _, name in ipairs(toolchain_dynamic_bins) do
                local target = path.join(bindir, name)
                if os.isfile(target) then
                    os.vrunv(patchelf.program, {"--set-interpreter", musl_loader, target})
                    os.vrunv(patchelf.program, {"--set-rpath", musl_lib_dir, target})
                    patched = patched + 1
                end
            end
        end
    end

    log.info("musl-gcc relocate: patched dynamic tools = %d", patched)
end

local function __relocate_specs()
    local install_dir = pkginfo.install_dir()
    local musl_lib_dir = path.join(install_dir, "x86_64-linux-musl", "lib")
    local musl_loader = path.join(musl_lib_dir, "libc.so")
    local specs_file = path.join(
        install_dir,
        "lib", "gcc", "x86_64-linux-musl", pkginfo.version(), "specs"
    )

    if not os.isfile(specs_file) then
        log.warn("musl-gcc relocate: specs file not found: %s", specs_file)
        return
    end

    local content = io.readfile(specs_file)
    local replace_linker = 0
    local replace_libdir = 0

    local function __gsub_plain(input, plain_pattern, replace_to)
        local escaped = plain_pattern:gsub("%p", "%%%1")
        return input:gsub(escaped, replace_to)
    end

    local xlings_loader_plain = "/home/xlings/.xlings_data/lib/ld-musl-x86_64.so.1"
    local xlings_loader_dynamic = "/[^%s%)%}]+/%.xlings_data/lib/ld%-musl%-x86_64%.so%.1"
    local system_loader_plain = "/lib/ld-musl-x86_64.so.1"

    local plain_xlings_loader_count = 0
    content, plain_xlings_loader_count = __gsub_plain(content, xlings_loader_plain, musl_loader)

    local dynamic_xlings_loader_count = 0
    content, dynamic_xlings_loader_count = content:gsub(
        xlings_loader_dynamic,
        musl_loader
    )

    local system_loader_count = 0
    content, system_loader_count = __gsub_plain(content, system_loader_plain, musl_loader)
    replace_linker = plain_xlings_loader_count + dynamic_xlings_loader_count + system_loader_count

    local plain_xlings_lib = "/home/xlings/.xlings_data/lib"
    local plain_xlings_lib_count = 0
    content, plain_xlings_lib_count = __gsub_plain(content, plain_xlings_lib, musl_lib_dir)

    local dynamic_xlings_lib_count = 0
    content, dynamic_xlings_lib_count = content:gsub(
        "/[^%s%)%}]+/%.xlings_data/lib",
        musl_lib_dir
    )
    replace_libdir = plain_xlings_lib_count + dynamic_xlings_lib_count

    io.writefile(specs_file, content)
    log.info(
        "musl-gcc relocate specs: linker=%d libdir=%d",
        replace_linker, replace_libdir
    )
end

function install()
    local gccdir = pkginfo.install_file()
        :replace(".tar.gz", "")
        :replace(".zip", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(gccdir, pkginfo.install_dir())
    __patch_toolchain_dynamic_bins()
    __relocate_specs()
    return true
end

function config()
    local gcc_bindir = path.join(pkginfo.install_dir(), "bin")

    -- binding tree - root node
    local binding_tree_root = "musl-gcc@" .. pkginfo.version()
    xvm.add("musl-gcc", {
        bindir = gcc_bindir,
        alias = "x86_64-linux-musl-gcc",
    })

    local __binding_tree_root = "x86_64-linux-musl-gcc@" .. pkginfo.version()
    xvm.add("x86_64-linux-musl-gcc", { bindir = gcc_bindir })

    for _, prog in ipairs(package.programs) do
        if prog ~= "musl-gcc" then
            xvm.add(prog, {
                bindir = gcc_bindir,
                alias = "x86_64-linux-" .. prog,
                binding = binding_tree_root,
            })
            -- full-name
            xvm.add("x86_64-linux-" .. prog, {
                bindir = gcc_bindir,
                binding = __binding_tree_root,
            })
        end
    end

-- runtime lib path (used by musl-ldd / musl-loader only)
    local musl_lib_dir = path.join(
        pkginfo.install_dir(),
        "x86_64-linux-musl", "lib"
    )

-- special commands: musl-ldd and musl-loader invoke libc.so (the musl
-- dynamic linker) via an alias wrapper, so RPATH cannot apply.  Setting
-- LD_LIBRARY_PATH directly is a deliberate, documented exception.
    xvm.add("musl-ldd", {
        version = "musl-gcc-" .. pkginfo.version(),
        bindir = musl_lib_dir,
        alias = "libc.so --list",
        envs = {
            LD_LIBRARY_PATH = musl_lib_dir,
        },
        binding = binding_tree_root,
    })

    xvm.add("musl-loader", {
        version = "musl-gcc-" .. pkginfo.version(),
        bindir = musl_lib_dir,
        alias = "libc.so",
        envs = {
            LD_LIBRARY_PATH = musl_lib_dir,
        },
        binding = binding_tree_root,
    })

    log.info("add static wrapper for musl-gcc ...")
    xvm.add("musl-gcc-static", { alias = "musl-gcc -static", binding = binding_tree_root })
    xvm.add("musl-g++-static", { alias = "musl-g++ -static", binding = binding_tree_root })

    return true
end

function uninstall()
    for _, prog in ipairs(package.programs) do
        xvm.remove(prog)
        xvm.remove("x86_64-linux-" .. prog)
    end
    -- special commands
    xvm.remove("musl-ldd", "musl-gcc-" .. pkginfo.version())
    xvm.remove("musl-loader", "musl-gcc-" .. pkginfo.version())
    xvm.remove("musl-gcc-static")
    xvm.remove("musl-g++-static")
    return true
end