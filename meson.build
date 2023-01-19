project('expidus-sdk', 'c', license: 'GPL-3.0-only', version: '0.2.0-alpha')

prefix = get_option('prefix')
bindir = prefix / get_option('bindir')
datadir = prefix / get_option('datadir')
libdir = prefix / get_option('libdir')
libexecdir = prefix / get_option('libexecdir')
localstatedir = get_option('localstatedir')
sysconfdir = get_option('sysconfdir')

flutter_engine = get_option('flutter-engine')
cipd = find_program('cipd', dirs: [get_option('cipd')], required: true)
