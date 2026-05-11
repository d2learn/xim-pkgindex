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
    -- Enumerate source entries via a single shell `ls` (one fork, one
    -- readdir — proot-safe). Then for each name, use `os.isdir` /
    -- `os.isfile` (the old runtime APIs that proot translates correctly)
    -- to test existence. Only entries that don't already exist in dst
    -- get a single `fs.symlink` call.
    --
    -- Why not fs.entries: even read-only fs.entries + fs.is_symlink +
    -- fs.is_file + fs.is_directory on 130 entries under proot is ~400+
    -- C++ std::filesystem stat() calls that proot traces via ptrace —
    -- enough to poison the talloc pool on some kernel/proot combos.
    -- The shell `ls` + Lua `os.isdir`/`os.isfile` path uses ~2N
    -- syscalls total (one readdir + one stat per entry) and goes
    -- through proot's simpler absolute-path translation, not the
    -- dir-fd-relative openat path.
    local f = io.popen(string.format([[ls -1 "%s" 2>/dev/null]], src_dir))
    if not f then return end
    local names = {}
    for line in f:lines() do
        local name = line:gsub("[\r\n]+$", "")
        if name ~= "" then table.insert(names, name) end
    end
    f:close()
    for _, name in ipairs(names) do
        local dst = path.join(dst_dir, name)
        -- Skip if anything already exists at dst (host bind-mount,
        -- prior package, or prior install). os.isdir/os.isfile cover
        -- real entries + symlinks that resolve to dirs/files.
        if os.isdir(dst) or os.isfile(dst) then
            -- already present, skip
        else
            local src = path.join(src_dir, name)
            fs.symlink(src, dst)
        end
    end
end

return sysroot
