# pnpm 包测试
if should_run "install"; then assert_install_success "pnpm"; fi
if should_run "verify"; then
    assert_command_works "pnpm --version" "pnpm --version"
fi
