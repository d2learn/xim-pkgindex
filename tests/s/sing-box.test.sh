# sing-box 包测试
if should_run "install"; then assert_install_success "sing-box"; fi
if should_run "verify"; then
    assert_command_works "sing-box version 2>&1 | head -1" "sing-box version"
    assert_xvm_registered "sing-box"
fi
