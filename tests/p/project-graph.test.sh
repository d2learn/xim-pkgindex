# project-graph 包测试
if should_run "install"; then assert_install_success "project-graph"; fi
if should_run "verify"; then
    assert_xvm_registered "project-graph"
fi
