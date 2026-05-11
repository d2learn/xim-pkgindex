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

-- Symlink each top-level entry in SRC_DIR into DST_DIR.
--
-- Only the immediate children of SRC_DIR are processed — directories
-- are linked as a whole (not recursively descended). This keeps the
-- number of proot-visible syscalls minimal (e.g. glibc: ~130 ops
-- instead of ~477; linux-headers: 11 instead of 937) and avoids a
-- proot heap-corruption bug triggered when hundreds of
-- fs.symlink+fs.remove+fs.mkdir_p calls poison proot's talloc pool
-- before a subsequent heavy operation (npm install 559 packages)
-- in the same proot session.
--
-- Behavior:
--   * Top-level directories in SRC → symlink to the source dir itself
--     (not a copy, not recursive descent). e.g. SRC/bits → DST/bits → SRC/bits
--   * Top-level regular files in SRC → symlink to the source file.
--   * Existing symlinks in SRC are re-linked with their original target.
--   * Existing entries at DST are removed first (force-overwrite).
--   * Missing SRC is a silent no-op.
function sysroot.install_headers(src_dir, dst_dir)
    if not os.isdir(src_dir) then return end
    fs.mkdir_p(dst_dir)
    for _, e in ipairs(fs.entries(src_dir) or {}) do
        local dst = path.join(dst_dir, e.name)
        fs.remove(dst)
        if e.type == "symlink" then
            local target = fs.readlink(e.path)
            if target then fs.symlink(target, dst) end
        else
            -- Both files and directories: symlink the entire entry
            fs.symlink(e.path, dst)
        end
    end
end

return sysroot
