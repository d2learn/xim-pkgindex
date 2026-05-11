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

-- Install headers from SRC_DIR into DST_DIR with lazy directory promotion.
--
-- Default behavior: symlink each top-level entry as a whole (one symlink
-- per dir or file). This keeps proot syscall count minimal (~143 total
-- across all 4 header packages vs ~1813 with per-file recursion) and
-- avoids proot's talloc heap-corruption on large syscall runs.
--
-- Multi-package merge (the "scsi/ problem"):
-- When two packages both ship a directory with the same name (e.g.
-- glibc has `scsi/{scsi.h, sg.h, ...}` and linux-headers has
-- `scsi/{scsi_bsg_fc.h, ...}`), the second package's install would
-- normally overwrite the first's symlink, losing the first's files.
--
-- Solution — "lazy promotion":
--   1. First package: DST/scsi doesn't exist → symlink to pkg-A/scsi  (1 op)
--   2. Second package: DST/scsi IS a symlink to a dir → PROMOTE:
--      - Read old target (pkg-A/scsi)
--      - Replace symlink with a real directory
--      - Symlink each entry from old target into the new real dir
--      - Symlink each entry from pkg-B/scsi into the new real dir
--   3. Third+ package: DST/scsi IS a real dir → just add our entries
--
-- This handles N packages with arbitrary overlapping directory names,
-- zero special-casing per directory. Non-conflicting entries stay as
-- whole-dir symlinks (zero overhead); only actual conflicts trigger
-- the promote-and-merge path.
function sysroot.install_headers(src_dir, dst_dir)
    if not os.isdir(src_dir) then return end
    fs.mkdir_p(dst_dir)
    for _, e in ipairs(fs.entries(src_dir) or {}) do
        local dst = path.join(dst_dir, e.name)

        if e.type == "directory" then
            if fs.is_symlink(dst) then
                -- PROMOTE: dst is a symlink to another package's dir.
                -- Replace with a real dir and merge both packages' entries.
                local old_target = fs.readlink(dst)
                fs.remove(dst)
                fs.mkdir_p(dst)
                -- Re-link old package's entries
                if old_target then
                    for _, oe in ipairs(fs.entries(old_target) or {}) do
                        local odst = path.join(dst, oe.name)
                        if not fs.is_symlink(odst) and not fs.is_file(odst) then
                            if oe.type == "symlink" then
                                local t = fs.readlink(oe.path)
                                if t then fs.symlink(t, odst) end
                            else
                                fs.symlink(oe.path, odst)
                            end
                        end
                    end
                end
                -- Link our entries
                for _, ne in ipairs(fs.entries(e.path) or {}) do
                    local ndst = path.join(dst, ne.name)
                    if not fs.is_symlink(ndst) and not fs.is_file(ndst) then
                        if ne.type == "symlink" then
                            local t = fs.readlink(ne.path)
                            if t then fs.symlink(t, ndst) end
                        else
                            fs.symlink(ne.path, ndst)
                        end
                    end
                end
            elseif fs.is_directory(dst) then
                -- dst is already a real dir (promoted by a prior merge).
                -- Recursively add our entries.
                sysroot.install_headers(e.path, dst)
            else
                -- dst exists but is a file — overwrite with our dir symlink
                fs.remove(dst)
                fs.symlink(e.path, dst)
            end
        else
            -- File or symlink entry — simple overwrite
            fs.remove(dst)
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
