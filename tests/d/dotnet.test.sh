# dotnet 包测试
if should_run "install"; then assert_install_success "dotnet"; fi
if should_run "verify"; then
    assert_command_works "dotnet --version | head -1" "dotnet --version"
    assert_xvm_registered "dotnet"
fi
