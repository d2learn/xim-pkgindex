# openssl 包测试
if should_run "install"; then assert_install_success "openssl"; fi
if should_run "verify"; then
    assert_command_works "openssl version" "openssl version"
fi
