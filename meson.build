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
valac = find_program('valac', native: false, required: true)

nix = find_program('nix', native: false, required: false)

host_system = target_machine.cpu() + '-' + target_machine.endian() + '-' + target_machine.system()
target_system = host_system
# TODO: add an option for specifing the target

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
conf_data.set('HOST_SYSTEM', host_system)
conf_data.set('TARGET_SYSTEM', target_system)

conf_data.set('SDK_DATADIR', sdk_datadir)
conf_data.set('SDK_LIBDIR', sdk_libdir)
conf_data.set('SDK_BINDIR', sdk_bindir)

conf_data.set('SH_PATH', sh.full_path())
conf_data.set('UNCRUSTIFY_PATH', uncrustify.full_path())
conf_data.set('CLANG_FORMAT_PATH', clang_format.full_path())
conf_data.set('VALAC_PATH', valac.full_path())

install_symlink('latest', install_dir: join_paths(datadir, 'expidus-sdk'), pointing_to: shortver)
install_symlink('latest', install_dir: join_paths(libdir, 'expidus-sdk'), pointing_to: shortver)

if nix.found()
  nix_channeldir = join_paths(sdk_libdir, 'nix', 'channel')

  install_subdir('lib', install_dir: nix_channeldir, strip_directory: false)
  install_subdir('nixos', install_dir: nix_channeldir, strip_directory: false)
  install_subdir('pkgs', install_dir: nix_channeldir, strip_directory: false)
  install_data('default.nix', install_dir: nix_channeldir)
  install_data('flake.nix', install_dir: nix_channeldir)
  install_data('data/flake-registry.json', install_dir: join_paths(sdk_libdir, 'nix'))

  conf_data.set('NIX_CHANNELDIR', nix_channeldir)

  nix_profiledir = join_paths(sdk_datadir, 'nix', 'profile')

  # TODO: make our custom nix profile

  conf_data.set('NIX_PROFILEDIR', nix_profiledir)
else
  conf_data.set('NIX_CHANNELDIR', '')
  conf_data.set('NIX_PROFILEDIR', '')
endif

subdir('data')
subdir('profile.d')
subdir('wrappers')
