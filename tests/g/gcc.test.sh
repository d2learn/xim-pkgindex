# gcc 包测试
if should_run "install"; then assert_install_success "gcc"; fi
if should_run "verify"; then
    assert_command_works "gcc --version | head -1" "gcc --version"
    assert_command_works "echo 'int main(){return 0;}' | gcc -x c - -o /tmp/xpkg_gcc_test && /tmp/xpkg_gcc_test && echo ok" "gcc 编译测试"
fi
