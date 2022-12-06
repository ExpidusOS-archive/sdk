foreach binname : ['clang-format', 'uncrustify', 'valac', 'zsh']
  configure_file(input: '@0@.in'.format(binname),
    output: binname,
    configuration: conf_data,
    install: true,
    install_dir: sdk_bindir,
    install_mode: 'rwxr-xr-x')
endforeach
