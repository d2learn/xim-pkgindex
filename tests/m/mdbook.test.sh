# mdbook 包测试
if should_run "install"; then assert_install_success "mdbook"; fi
if should_run "verify"; then
    assert_command_works "mdbook --version" "mdbook --version"
    assert_xvm_registered "mdbook"
fi
