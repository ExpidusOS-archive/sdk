private const string GETTEXT_PACKAGE = "expidus-system";

private bool arg_json = false;

private const GLib.OptionEntry[] options = {
  { "json", 'j', GLib.OptionFlags.NONE, GLib.OptionArg.NONE, ref arg_json, N_("Prints in a JSON friendly way"), null },
  { null }
};

public static int main(string[] args) {
  var arg0 = Posix.realpath(args[0]);
  var is_sdk = arg0 == ExpidusSDK.LIBDIR + "/bin/expidus-version";
  var is_system = arg0 == Config.BINDIR + "/expidus-version"; 

  GLib.Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
  if (is_system) GLib.Intl.bindtextdomain(GETTEXT_PACKAGE, Config.DATADIR + "/locale");
  else if (is_sdk) GLib.Intl.bindtextdomain(GETTEXT_PACKAGE, ExpidusSDK.DATADIR + "/locale");
  else GLib.Intl.bindtextdomain(GETTEXT_PACKAGE, Config.BUILDDIR + "/system/po");

  try {
    var optctx = new GLib.OptionContext(N_("- \"nixos-version\"-like command but for ExpidusOS"));
    optctx.set_help_enabled(true);
    optctx.add_main_entries(options, null);
    optctx.parse(ref args);
  } catch (GLib.Error e) {
    stderr.printf(N_("Failed to handle arguments: %s:%d: %s\n"), e.domain.to_string(), e.code, e.message);
    return 1;
  }

  var codename = N_("Willamette");

  if (args.length == 2) {
    switch (args[1]) {
      case "codename":
        if (arg_json) stdout.printf("\"%s\"\n", codename);
        else stdout.printf("%s\n", codename);
        return 0;
      case "codenameId":
        if (arg_json) stdout.printf("\"%s\"\n", ExpidusSDK.VERSION_CODENAME);
        else stdout.printf("%s\n", ExpidusSDK.VERSION_CODENAME);
        return 0;
      case "version":
        if (arg_json) stdout.printf("\"%s\"\n", ExpidusSDK.VERSION);
        else stdout.printf("%s\n", ExpidusSDK.VERSION);
        return 0;
      case "machines":
      case "machine":
        if (arg_json) {
          if (!is_system) {
            stdout.printf("{\n");
            stdout.printf("\t\"target\": \"%s\",\n", ExpidusSDK.TARGET_SYSTEM);
            stdout.printf("\t\"host\": \"%s\"\n", ExpidusSDK.HOST_SYSTEM);
            stdout.printf("}\n");
          } else {
            stdout.printf("\"%s\"\n", ExpidusSDK.TARGET_SYSTEM);
          }
        } else {
          if (!is_system) {
            stdout.printf(N_("Target: %s\n"), ExpidusSDK.TARGET_SYSTEM);
            stdout.printf(N_("Host: %s\n"), ExpidusSDK.HOST_SYSTEM);
          } else {
            stdout.printf("%s\n", ExpidusSDK.TARGET_SYSTEM);
          }
        }
        return 0;
      default:
        stderr.printf(N_("Unrecognized field: %s\n"), args[1]);
        return 1;
    }
  } else if (args.length > 2) {
    stderr.printf(N_("Too many arguments, limit is 2"));
    return 1;
  }

  if (arg_json) {
    stdout.printf("{\n");
    stdout.printf("\t\"codename\": \"%s\",\n", codename);
    stdout.printf("\t\"codenameId\": \"%s\",\n", ExpidusSDK.VERSION_CODENAME);
    stdout.printf("\t\"version\": \"%s\",\n", ExpidusSDK.VERSION);
    if (!is_system) {
      stdout.printf("\t\"machines\": {\n");
      stdout.printf("\t\t\"target\": \"%s\",\n", ExpidusSDK.TARGET_SYSTEM);
      stdout.printf("\t\t\"host\": \"%s\"\n", ExpidusSDK.HOST_SYSTEM);
      stdout.printf("\t}\n");
    } else {
      stdout.printf("\t\"machine\": \"%s\"\n", ExpidusSDK.TARGET_SYSTEM);
    }
    stdout.printf("}\n");
    return 0;
  }

  stdout.printf(N_("ExpidusOS %s (%s)\n"), ExpidusSDK.VERSION, codename);
  return 0;
}
