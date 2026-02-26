# nvm 包测试
# nvm 是 shell 函数, 无法通过 xvm shim 验证, 只测安装
if should_run "install"; then assert_install_success "nvm"; fi
if should_run "verify"; then
    assert_command_works "bash -c 'source ~/.nvm/nvm.sh && nvm --version'" "nvm --version (via source)"
fi
