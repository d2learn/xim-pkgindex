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

-- Install headers from SRC_DIR into DST_DIR — strictly non-recursive.
--
-- Only the immediate children of SRC_DIR are processed. Each entry
-- that doesn't already exist in DST_DIR gets a single symlink; entries
-- that already exist (from the host bind-mount or from another package)
-- are skipped entirely.
--
-- This "skip-if-exists" policy is correct for sysroot headers because:
--   * If the host already has `/usr/include/sys/` (233 real dirs on a
--     typical Ubuntu bind-mount), those headers are already usable by
--     the subos GCC — we don't need to replace or merge them.
--   * If a prior xlings package already symlinked `scsi/` → pkg-A's
--     dir, and now pkg-B also has `scsi/`, pkg-B's entries are a
--     superset concern of the caller (who should ship a merged dir
--     or use a different name), not this helper's.
--   * Crucially, this keeps the proot syscall count at ≤ N where N is
--     the number of top-level entries in SRC_DIR (~130 for glibc),
--     regardless of how large the destination tree is. The previous
--     "recurse into existing real dirs" path blew up to 500+ ops when
--     glibc's 20 subdirs overlapped with Ubuntu's host `/usr/include`
--     (e.g. sys/ alone has 87 host entries), poisoning proot's talloc
--     pool and crashing npm install in the same session.
function sysroot.install_headers(src_dir, dst_dir)
    if not os.isdir(src_dir) then return end
    fs.mkdir_p(dst_dir)
    for _, e in ipairs(fs.entries(src_dir) or {}) do
        local dst = path.join(dst_dir, e.name)

        -- Skip if anything already exists at dst — host bind-mount,
        -- prior package symlink, or promoted dir. Don't touch it.
        if fs.is_symlink(dst) or fs.is_file(dst) or fs.is_directory(dst) then
            -- already present, skip
        else
            -- Entry doesn't exist yet → symlink it
            if e.type == "symlink" then
                local target = fs.readlink(e.path)
                if target then fs.symlink(target, dst) end
            else
                fs.symlink(e.path, dst)
            end
        end
    end
end

return sysroot
