# seeme-server 包测试
if should_run "install"; then assert_install_success "seeme-server"; fi
if should_run "verify"; then
    assert_xvm_registered "seeme-server"
fi
