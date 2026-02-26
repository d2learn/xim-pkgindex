# khistory 包测试
if should_run "install"; then assert_install_success "khistory"; fi
if should_run "verify"; then
    assert_xvm_registered "khistory"
fi
