package = {
    spec = "1",
    name = "nvm",
    description = "Node Version Manager",
    homepage = "https://github.com/nvm-sh/nvm",
    authors = {"Tim Caswell"},
    maintainers = {"https://github.com/nvm-sh/nvm?tab=readme-ov-file#maintainers"},
    licenses = {"MIT"},
    type = "config",
    repo = "https://github.com/nvm-sh/nvm",
    docs = "https://github.com/nvm-sh/nvm#installing-and-updating",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"tools", "nodejs"},

    xpm = {
        windows = {
            -- Windows still uses coreybutler/nvm-windows — a separate
            -- project from POSIX nvm; ships a real .exe installer.
            -- Not covered by the xlings-res mirror (mirror is for
            -- POSIX nvm only).
            ["latest"] = { ref = "1.1.11"},
            ["1.1.11"] = {
                url = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.11/nvm-setup.exe",
                sha256 = "941561b7486cffc5b5090a99f6949bdc31dbaa6288025d4b2b1e3f710f0ed654",
            }
        },
        linux = {
            -- Mirror at xlings-res/nvm (byte-identical to upstream
            -- nvm-sh/nvm source tarball, just renamed to xlings-res
            -- convention). XLINGS_RES sentinel resolves to:
            --   GLOBAL → github.com/xlings-res/nvm/releases/...
            --   CN     → gitcode.com/xlings-res/nvm/releases/...
            --
            -- Why we mirror instead of pointing at upstream:
            --   * Stable URL shape under xlings-res/<pkg> across both
            --     GLOBAL and CN mirrors (CN users get gitcode-served
            --     downloads automatically — important for nvm because
            --     download speed from raw.githubusercontent.com to
            --     mainland China is unreliable)
            --   * upstream `archive/refs/tags/...` URLs are
            --     auto-generated, theoretically stable but not
            --     promised stable by GitHub
            --
            -- Bumped 0.39.0 → 0.40.4 (latest upstream as of mirror
            -- creation). Going forward bumps are: download upstream
            -- source tarball → re-upload as
            -- nvm-<ver>-{linux-x86_64,macosx-arm64}.tar.gz to
            -- xlings-res/nvm release page → bump version line here.
            ["latest"] = { ref = "0.40.4"},
            ["0.40.4"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")

function installed()
    return os.iorun("nvm --version")
end

function install()
    if os.host() == "windows" then
        os.exec(pkginfo.install_file() .. " /SILENT")

        local nvm_home = "C:\\Users\\" .. os.getenv("USERNAME") .. "\\AppData\\Roaming\\nvm"
        local node_home = "C:\\Program Files\\nodejs"

        os.setenv("NVM_HOME", nvm_home)
        os.setenv("NVM_SYMLINK", node_home)

        -- update path
        os.addenv("PATH", nvm_home)
        os.addenv("PATH", node_home)
    else
        -- Bypass nvm-sh's `install.sh`. The upstream installer ends
        -- with `for job in $(jobs -p); do wait "$job"; done` — but
        -- `dash` (Ubuntu/Debian's default `/bin/sh`) does NOT enable
        -- job control for non-interactive scripts (POSIX), so
        -- `jobs -p` returns empty, the `for` body never runs, the
        -- shell exits immediately while three backgrounded `wget &`
        -- children are still downloading. Net effect from xlings's
        -- POV is "install ok" while the user terminal hangs at "100%".
        --
        -- The installer's only job is laying down 3 files in
        -- ~/.nvm/. Replacing it with a single `tar xz` of the
        -- pre-mirrored upstream source tarball is equivalent and
        -- avoids the dash compat trap entirely.
        local nvm_home = path.join(os.getenv("HOME"), ".nvm")
        os.tryrm(nvm_home)
        os.mkdir(nvm_home)
        -- Upstream tarball top-level dir is `nvm-<version>/`; flatten
        -- into ~/.nvm so existing `[ -s "$NVM_DIR/nvm.sh" ] && \. ...`
        -- profile snippet keeps working unchanged.
        system.exec(string.format(
            [[tar -xzf "%s" -C "%s" --strip-components=1]],
            pkginfo.install_file(), nvm_home
        ))

        system.unix_api().append_to_shell_profile({
            posix = [[
# nvm config by xlings-xim
if [ "$NVM_DIR" == "" ]; then export NVM_DIR="$HOME/.nvm"; fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"]],
            fish = [[
# nvm config by xlings-xim
if not set -q NVM_DIR; set -gx NVM_DIR "$HOME/.nvm"; end]],
        })
    end
    return true
end

function uninstall()
    if os.host() == "windows" then
        -- TODO: uninstall nvm-windows
    else
        local nvm_home = path.join(os.getenv("HOME"), ".nvm")
        os.tryrm(nvm_home)
    end
    return true
end