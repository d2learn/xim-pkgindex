# nvim 包测试
if should_run "install"; then assert_install_success "nvim"; fi
if should_run "verify"; then
    assert_command_works "nvim --version | head -1" "nvim --version"
    assert_xvm_registered "nvim"
    assert_xvm_registered "neovim"
fi
