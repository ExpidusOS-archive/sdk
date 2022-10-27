configure_file(input: 'data/lsb-release.in', output: 'lsb-release',
  configuration: conf_data,
  install: true,
  install_dir: sdk_sysconfdir)

configure_file(input: 'data/os-release.in', output: 'os-release',
  configuration: conf_data,
  install: true,
  install_dir: sdk_sysconfdir)

configure_file(input: 'src/expidus-sdk.h.in', output: 'expidus-sdk.h',
  configuration: conf_data,
  install: true,
  install_dir: join_paths(sdk_libdir, 'include'))

config_vala = configure_file(input: 'src/config.vala.in', output: 'config.vala',
  configuration: conf_data)

install_subdir('vapi', install_dir: sdk_libdir)

executable('expidus-version', 'src/expidus-version.vala', config_vala,
  c_args: ['-DGETTEXT_PACKAGE=expidus-system'],
  dependencies: [glib, sdk_dep, posix],
  install: true,
  install_dir: sdk_bindir)

subdir('po')
