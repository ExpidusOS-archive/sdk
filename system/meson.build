configure_file(input: 'src/expidus-sdk.h.in', output: 'expidus-sdk.h',
  configuration: conf_data,
  install: true,
  install_dir: join_paths(sdk_libdir, 'include'))

expidus_sdk_dep = meson.get_compiler('vala').find_library('expidus-sdk', dirs: [join_paths(meson.current_source_dir(), 'vapi')])

install_subdir('vapi', install_dir: sdk_libdir)

executable('expidus-version', 'src/expidus-version.vala',
  dependencies: [glib, expidus_sdk_dep],
  install: true,
  install_dir: sdk_bindir)

#subdir('po')
