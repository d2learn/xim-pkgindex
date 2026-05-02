package = {
    spec = "1",
    -- base info
    name = "musl-gcc",
    description = "GCC, the GNU Compiler Collection (prebuilt with musl)",

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
            -- patchelf is required by __patch_toolchain_dynamic_bins() in
            -- install() — the prebuilt tarball ships every binutils binary
            -- (~16 entries under bin/x86_64-linux-musl-* AND under
            -- x86_64-linux-musl/bin/) with PT_INTERP hardcoded to the
            -- canonical /home/xlings/.xlings_data/lib/ld-musl-x86_64.so.1
            -- path. Without patchelf at install time the relocation step
            -- silently no-ops (os.exec falls back), and the toolchain only
            -- runs on machines where that exact canonical path resolves —
            -- breaking any non-default XLINGS_HOME, container, fresh
            -- machine, or "first ever musl-gcc install" scenario. Declaring
            -- the dep guarantees patchelf is on the install-hook PATH.
            deps = { "xim:patchelf@0.18.0" },

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
    os.exec("patchelf --version")

    for _, bindir in ipairs(bindirs) do
        if os.isdir(bindir) then
            for _, name in ipairs(toolchain_dynamic_bins) do
                local target = path.join(bindir, name)
                if os.isfile(target) then
                    os.exec(string.format(
                        "patchelf --set-interpreter %q %q",
                        musl_loader, target
                    ))
                    os.exec(string.format(
                        "patchelf --set-rpath %q %q",
                        musl_lib_dir, target
                    ))
                    patched = patched + 1
                end
            end
        end
    end

    log.info("musl-gcc relocate: patched dynamic tools = %d", patched)
end

-- ─────────────────────────────────────────────────────────────────────
-- gcc-flavor cross-registration
--
-- A musl-gcc install also publishes itself under the standard `gcc` family
-- of program names with version suffix `-musl` (e.g. `15.1.0-musl`). Users
-- can then switch flavors via:
--   xlings use gcc 15.1.0          # glibc
--   xlings use gcc 15.1.0-musl     # musl
--
-- The cross-registered programs form their own binding subtree rooted at
-- `xim-musl-gnu-gcc@<flavor_ver>`, parallel to xim:gcc.lua's
-- `xim-gnu-gcc@<ver>`. Keeping this tree separate from the primary
-- `musl-gcc@<ver>` tree (which holds musl-gcc / musl-g++ / x86_64-linux-musl-*
-- / musl-ldd / musl-loader / musl-gcc-static / musl-g++-static) means the
-- gcc-flavor view in `xlings info gcc` is not entangled with musl-gcc's
-- internal program shimming, and removal of one flavor's registrations
-- doesn't reach into the other.
--
-- Why the suffix and not a prefix:
--   xvm's match_version splits versions on `.` and parses each segment with
--   from_chars; `15.1.0-musl` parses cleanly as 15/1/0(-musl) so it sorts
--   alongside `15.1.0`, while `musl-15.1.0` sorts as 0.1.0 (`musl-15` parses
--   as 0). Both forms are still distinct from `15.1.0` under prefix_matches
--   so `xlings use gcc 15.1.0` will not accidentally pick up the musl row.
--
-- Why only the frontends (gcc/g++/c++/cpp/cc):
--   GCC drives cc1/as/ld via toolchain-internal paths, not PATH, so the
--   compile/link pipeline is fully covered by the frontend shim. ar/nm/
--   ranlib/strip operate on ELF and don't depend on libc flavor; the host
--   binutils handles musl-produced .o/.a files fine, no need to remap them.
--
-- Why `-Wl,--dynamic-linker=...`/`-rpath` but NOT `--sysroot`:
--   musl-gcc's toolchain is self-contained: its `x86_64-linux-musl/{include,
--   lib}` already serves as the sysroot, so `--sysroot=...` would mis-point
--   to subos's glibc headers. Linking, however, defaults to musl's standard
--   `/lib/ld-musl-x86_64.so.1` dynamic linker which doesn't exist on glibc
--   hosts; remap to the toolchain-shipped libc.so (musl: libc.so doubles as
--   the dynamic linker) and add rpath so dynamic binaries Just Work. Static
--   builds ignore both flags.
-- ─────────────────────────────────────────────────────────────────────

local __gcc_flavor_progs = {
    ["gcc"] = "x86_64-linux-musl-gcc",
    ["g++"] = "x86_64-linux-musl-g++",
    ["c++"] = "x86_64-linux-musl-c++",
    ["cpp"] = "x86_64-linux-musl-cpp",
    ["cc"]  = "x86_64-linux-musl-gcc",
}

local function __gcc_flavor_version()
    return pkginfo.version() .. "-musl"
end

local function __gcc_flavor_root_name()
    return "xim-musl-gnu-gcc"
end

local function __gcc_flavor_alias_args()
    local musl_lib_dir = path.join(
        pkginfo.install_dir(), "x86_64-linux-musl", "lib"
    )
    local musl_loader = path.join(musl_lib_dir, "libc.so")
    return string.format(
        " -Wl,--dynamic-linker=%s -Wl,-rpath,%s",
        musl_loader, musl_lib_dir
    )
end

local function __register_as_gcc_flavor()
    local gcc_bindir = path.join(pkginfo.install_dir(), "bin")
    local flavor_ver = __gcc_flavor_version()
    local alias_args = __gcc_flavor_alias_args()
    local root_name = __gcc_flavor_root_name()
    local flavor_root = string.format("%s@%s", root_name, flavor_ver)

    log.info("registering musl-gcc as gcc flavor %s (root: %s) ...",
             flavor_ver, flavor_root)

    -- Anchor a virtual root node for this flavor's subtree.
    xvm.add(root_name)

    for prog, target in pairs(__gcc_flavor_progs) do
        xvm.add(prog, {
            bindir  = gcc_bindir,
            alias   = target .. alias_args,
            version = flavor_ver,
            binding = flavor_root,
        })
    end
end

local function __unregister_gcc_flavor()
    local flavor_ver = __gcc_flavor_version()
    for prog, _ in pairs(__gcc_flavor_progs) do
        xvm.remove(prog, flavor_ver)
    end
    -- Drop the virtual root only if no other musl-gcc version still hangs
    -- registrations off it (xvm.remove on an empty target is a no-op there).
    xvm.remove(__gcc_flavor_root_name())
end

local function __remove_specs()
    local install_dir = pkginfo.install_dir()
    local specs_file = path.join(
        install_dir,
        "lib", "gcc", "x86_64-linux-musl", pkginfo.version(), "specs"
    )

    if not os.isfile(specs_file) then
        log.info("musl-gcc: specs file not found, skip remove: %s", specs_file)
        return
    end

    os.tryrm(specs_file)
    log.info("musl-gcc: removed specs file: %s", specs_file)
end

function install()
    local gccdir = pkginfo.install_file()
        :replace(".tar.gz", "")
        :replace(".zip", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(gccdir, pkginfo.install_dir())
    __patch_toolchain_dynamic_bins()
    __remove_specs()
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

    __register_as_gcc_flavor()

    return true
end

function uninstall()
    __unregister_gcc_flavor()
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