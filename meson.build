project('expidus-sdk', license: 'GPL-3.0-only', version: '0.2.0-alpha')

fs = import('fs')

prefix = get_option('prefix')
bindir = prefix / get_option('bindir')
datadir = prefix / get_option('datadir')
libdir = prefix / get_option('libdir')
libexecdir = prefix / get_option('libexecdir')
localstatedir = get_option('localstatedir')
sysconfdir = get_option('sysconfdir')

longver = '@0@'.format(meson.project_version())
shortver = longver
git = find_program('git', native: true, required: false)
conf_data = configuration_data()

if git.found()
  git_commit = run_command([git, 'rev-parse', '--short', 'HEAD'])
  git_branch = run_command([git, 'rev-parse', '--abbrev-ref', 'HEAD'])
  git_config_username = run_command([git, 'config', '--get', 'user.name'])

  if git_commit.returncode() == 0 and git_branch.returncode() == 0
    shortver = '@0@-@1@'.format(meson.project_version(), git_commit.stdout().strip())
    longver = '@0@ (branch \'@1@\')'.format(shortver, git_branch.stdout().strip())
  endif

  if git_config_username.returncode() == 0
    git_username = git_config_username.stdout().strip()
    conf_data.set('BUILD_USER', git_username)
  endif
endif

sh = find_program('sh', native: false, required: true)
uncrustify = find_program('uncrustify', native: false, required: true)
clang_format = find_program('clang-format', native: false, required: true)

target_system = target_machine.cpu() + '-' + target_machine.endian() + '-' + target_machine.system()

sdk_datadir = join_paths(datadir, 'expidus-sdk', shortver, target_system)
sdk_libdir = join_paths(libdir, 'expidus-sdk', shortver, target_system)
sdk_bindir = join_paths(sdk_libdir, 'bin')

conf_data.set('PREFIX', prefix)
conf_data.set('BINDIR', bindir)
conf_data.set('DATADIR', datadir)
conf_data.set('LIBDIR', libdir)
conf_data.set('LIBEXECDIR', libexecdir)
conf_data.set('VERSION', longver)
conf_data.set('BUILDDIR', meson.current_build_dir())
conf_data.set('SOURCEDIR', meson.current_source_dir())

conf_data.set('SDK_DATADIR', sdk_datadir)
conf_data.set('SDK_LIBDIR', sdk_libdir)
conf_data.set('SDK_BINDIR', sdk_bindir)

conf_data.set('SH_PATH', sh.full_path())
conf_data.set('UNCRUSTIFY_PATH', uncrustify.full_path())
conf_data.set('CLANG_FORMAT_PATH', clang_format.full_path())

install_symlink('latest', install_dir: join_paths(datadir, 'expidus-sdk'), pointing_to: shortver)
install_symlink('latest', install_dir: join_paths(libdir, 'expidus-sdk'), pointing_to: shortver)

subdir('data')
subdir('profile.d')
subdir('wrappers')
