-- Shared sysroot installation helpers for xim-pkgindex.
--
-- Loaded by package config() hooks via:
--     import("xim.pkgindex.sysroot")
--
-- Requires xlings >= 0.4.29 (libxpkg fs module + `xim.pkgindex.*`
-- custom-module loader, both shipped in xlings v0.4.29 / libxpkg v0.0.40).
-- Older xlings versions have no `xim.pkgindex.*` resolver, so the import
-- falls through to the unknown-module stub and any callsite hits a nil
-- error — that's the right signal to bump xlings.

import("xim.libxpkg.fs")

local sysroot = {}

-- Recursively materialize SRC_DIR into DST_DIR as a tree of symlinks.
--
-- Why symlink instead of copy:
--   * Avoids the proot sandbox `Permission denied` triggered by `cp -r`
--     (recursive openat into an existing destination subtree).
--   * Each operation here (fs.mkdir_p / fs.symlink / fs.readlink /
--     fs.remove) is a single absolute-path syscall — translates
--     correctly under proot.
--   * No file duplication, sysroot view stays in sync with the package
--     install dir, and uninstalling the package correctly leaves
--     dangling links (headers should not be available without their
--     library).
--
-- Behavior:
--   * Regular files in SRC become symlinks in DST pointing at SRC/<rel>.
--   * Existing symlinks are preserved by reading their original target
--     and recreating the link with the same target in DST.
--   * Existing entries at DST are removed first (force-overwrite).
--   * Missing SRC is a silent no-op.
function sysroot.install_headers(src_dir, dst_dir)
    if not os.isdir(src_dir) then return end
    fs.mkdir_p(dst_dir)
    for _, e in ipairs(fs.entries(src_dir) or {}) do
        local dst = path.join(dst_dir, e.name)
        if e.type == "directory" then
            sysroot.install_headers(e.path, dst)
        elseif e.type == "symlink" then
            fs.remove(dst)
            local target = fs.readlink(e.path)
            if target then fs.symlink(target, dst) end
        else
            fs.remove(dst)
            fs.symlink(e.path, dst)
        end
    end
end

return sysroot
