{ lib, fetchgit, fetchFromGitHub }:
with lib;
let
  fetchFromGoogle = { owner, repo, fetchSubmodules ? false, rev ? "HEAD", sha256 }: fetchgit {
    url = "https://${owner}.googlesource.com/${repo}.git";
    inherit rev sha256 fetchSubmodules;
    leaveDotGit = true;
  };
in {
  src = fetchFromGitHub {
    owner = "flutter";
    repo = "buildroot";
    rev = "6af51ff4b86270cc61517bff3fff5c3bb11492e1";
    sha256 = "sha256-77QseVLpSaJf3OaeJsOVzGwDjkQSpcbmZ2qUnhxz1l4=";
    leaveDotGit = true;
  };
  "src/third_party/abseil-cpp" = fetchFromGoogle {
    owner = "chromium";
    repo = "chromium/src/third_party/abseil-cpp";
    rev = "2d8c1340f0350828f1287c4eaeebefcf317bcfc9";
    sha256 = "sha256-MYwKhYwTDGWul63Py2iqljjQXSZPEsY7jO6QGL17NDg=";
  };
  "src/third_party/angle" = fetchFromGoogle {
    owner = "chromium";
    repo = "angle/angle";
    rev = "3faaded8234b31dea24c929e40e33089a34a9aa5";
    sha256 = "sha256-uWTLO4clHsdNyTlVPYyVG8dCYWf/p2WPs/SbGkgoREo=";
  };
  "src/third_party/benchmark" = fetchFromGitHub {
    owner = "google";
    repo = "benchmark";
    rev = "431abd149fd76a072f821913c0340137cc755f36";
    sha256 = "sha256-mPB+Yo8TGwwsg4NiiKDlvWDCO9aye03D81VQ6zK+E68=";
    leaveDotGit = true;
  };
  "src/third_party/boringssl" = fetchFromGitHub {
    owner = "dart-lang";
    repo = "boringssl_gen";
    rev = "ced85ef0a00bbca77ce5a91261a5f2ae61b1e62f";
    sha256 = "sha256-0lnGkWZyq1iyl4AP4NTTwjBvr3mxk322FOTd4prSEpo=";
    leaveDotGit = true;
  };
  "src/third_party/boringssl/src" = fetchFromGoogle {
    owner = "boringssl";
    repo = "boringssl";
    rev = "87f316d7748268eb56f2dc147bd593254ae93198";
    sha256 = "sha256-/aOCl2URPJt2IenEavxM0mk0fI2Y9oXTXpx1VqZg2sc=";
  };
  "src/third_party/colorama/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/colorama";
    rev = "799604a1041e9b3bc5d2789ecbd7e8db2e18e6b8";
    sha256 = "sha256-ut4fW39OEELb3ZNl7tJQmiU4vY/uJK6uwHMQXyMUvyQ=";
  };
  "src/third_party/dart" = fetchFromGoogle {
    owner = "dart";
    repo = "sdk";
    rev = "b6592742d9f1a82af319f46eda3d59a61e89b91b";
    sha256 = "sha256-L9C+oIQ8iHK+GTqy1b6kJEO4LHFWaNQA9Ahu/Y0fBms=";
  };
  "src/third_party/dart/third_party/pkg/args" = fetchFromGoogle {
    owner = "dart";
    repo = "args";
    rev = "73e8d3b55cbedc9765f8e266f3422d8914f8e62a";
    sha256 = "sha256-xuWVIc6hEQkpOew7LPF82yOqnRH+K2KW7IMHflBkPN0=";
  };
  "src/third_party/dart/third_party/pkg/async" = fetchFromGoogle {
    owner = "dart";
    repo = "async";
    rev = "f3ed5f690e2ec9dbe1bfc5184705575b4f6480e5";
    sha256 = "sha256-1i3NxNrWmZD/yKdmlE+AufJ6XtfvxVD2z+S6jgb+Oes=";
  };
  "src/third_party/dart/third_party/pkg/bazel_worker" = fetchFromGoogle {
    owner = "dart";
    repo = "bazel_worker";
    rev = "9710de6c9c70b1b583183db9d9721ba64e5a16fe";
    sha256 = "sha256-lgMLOfIMD0Vw4qI1ck2Oj3qCN/mq6lz+jQJkV7EikvE=";
  };
  "src/third_party/dart/third_party/pkg/boolean_selector" = fetchFromGoogle {
    owner = "dart";
    repo = "boolean_selector";
    rev = "1d3565e2651d16566bb556955b96ea75018cbd0c";
    sha256 = "sha256-DYur3jT9dcNV6ajkntm9y8P6yQF1/LMJrkxOnFt/KjE=";
  };
  "src/third_party/dart/third_party/pkg/browser_launcher" = fetchFromGoogle {
    owner = "dart";
    repo = "browser_launcher";
    rev = "981ca8847dd2b0fe022f9e742045cfb8f214d35f";
    sha256 = "sha256-CEOJzNbE3sbXwhNgxqy4JwVP9w2EylDS7MHTmS5ufBM=";
  };
  "src/third_party/dart/third_party/pkg/cli_util" = fetchFromGoogle {
    owner = "dart";
    repo = "cli_util";
    rev = "b0adbba89442b2ea6fef39c7a82fe79cb31e1168";
    sha256 = "sha256-uGYqxigZ24c8uPtsCnSuBYBXZ318fwSkR//wSKMhgt4=";
  };
  "src/third_party/dart/third_party/pkg/clock" = fetchFromGoogle {
    owner = "dart";
    repo = "clock";
    rev = "2507a228773c5e877fc9e3330080b234aad965c0";
    sha256 = "sha256-C7XKmZli8RPg3BLskJXthEI6+KKzYWqF5upOOgOnprk=";
  };
  "src/third_party/dart/third_party/pkg/collection" = fetchFromGoogle {
    owner = "dart";
    repo = "collection";
    rev = "414ffa1bc8ba18bd608bbf916d95715311d89ac1";
    sha256 = "sha256-aq9EjlZ1bo8KFygO1f0C3jAeGmzcYJG8L8m612V3qs8=";
  };
  "src/third_party/dart/third_party/pkg/convert" = fetchFromGoogle {
    owner = "dart";
    repo = "convert";
    rev = "7145da14f9cd730e80fb4c6a10108fcfd205e8e7";
    sha256 = "sha256-Hq18m2Iz+kxAWFFPXVc1xyszmtaj15WPPdPZc4yYPkY=";
  };
  "src/third_party/dart/third_party/pkg/crypto" = fetchFromGoogle {
    owner = "dart";
    repo = "crypto";
    rev = "223e0a62c0f762fd2b510f753861445b52e14fc3";
    sha256 = "sha256-I2gPMpPpOwMG+rP9RzISeLCSVZcVsW0Ef4JxWExF1lI=";
  };
  "src/third_party/dart/third_party/pkg/csslib" = fetchFromGoogle {
    owner = "dart";
    repo = "csslib";
    rev ="ba2eb2d80530eedefadaade338a09c2dd60410f3";
    sha256 = "sha256-3gt+XT7Ft6fQbjcnd05NDVbGhYWSLJsds1yI88m12Ps=";
  };
  "src/third_party/dart/third_party/pkg/dart_style" = fetchFromGoogle {
    owner = "dart";
    repo = "dart_style";
    rev = "d7b73536a8079331c888b7da539b80e6825270ea";
    sha256 = "sha256-qz8Wt0fVJbg8Z4E2Bqrpk0qG8eh3lfJiDzn67E0Lrtw=";
  };
  "src/third_party/dart/third_party/pkg/dartdoc" = fetchFromGoogle {
    owner = "dart";
    repo = "dartdoc";
    rev = "adc5a45ddafb57e3a600ee7d9e88dc81061d1410";
    sha256 = "sha256-c00MWskBZCcve3icMkzn2f8Zbd80+XkVYVVMaGKrnx4=";
  };
  "src/third_party/dart/third_party/pkg/ffi" = fetchFromGoogle {
    owner = "dart";
    repo = "ffi";
    rev = "18b2b549d55009ff594600b04705ff6161681e07";
    sha256 = "sha256-eeOja1e62N3bZ/GrnLAWRWZz3ZgLe09293GPHJbsMOk=";
  };
  "src/third_party/dart/third_party/pkg/file" = fetchFromGoogle {
    owner = "dart";
    repo = "external/github.com/google/file.dart";
    rev = "0132eeedea2933513bf230513a766a8baeab0c4f";
    sha256 = "sha256-SdFcU27aP00Wlak1V4K87z5TZtpdNe2cEeI3lQAn8XI=";
  };
  "src/third_party/dart/third_party/pkg/fixnum" = fetchFromGoogle {
    owner = "dart";
    repo = "fixnum";
    rev = "164712f6547cdfb2709b752188186baf31fd1730";
    sha256 = "sha256-bsNsivasTYWnbkf2tOINLIY7sVZTHkuw1r0HlL8wb1k=";
  };
  "src/third_party/dart/third_party/pkg/glob" = fetchFromGoogle {
    owner = "dart";
    repo = "glob";
    rev = "1d51fcc172e5adfbae6e82c3f8f119774cb2fca2";
    sha256 = "sha256-x41ICIqO30Iw48azYYvBW+r74bGY0puXN6AFJwtpVfg=";
  };
  "src/third_party/dart/third_party/pkg/html" = fetchFromGoogle {
    owner = "dart";
    repo = "html";
    rev = "8243e967caad9932c13971af3b2a7c8f028383d5";
    sha256 = "sha256-Oa/uGVFoxX4vhqRZF18BJZrS0w5rbXELqoATZU1JILM=";
  };
  "src/third_party/dart/third_party/pkg/http" = fetchFromGoogle {
    owner = "dart";
    repo = "http";
    rev = "843c5ecb1ea2233ba7b7049833b5801b149fba86";
    sha256 = "sha256-2Z4n2LhUEzrJ2a8N5AnPCDctvgfIgnMsqdjKpMZLtvE=";
  };
  "src/third_party/dart/third_party/pkg/http_multi_server" = fetchFromGoogle {
    owner = "dart";
    repo = "http_multi_server";
    rev = "20bf079c8955d1250a45afb9cb096472a724a551";
    sha256 = "sha256-S4fIiwnWWgmzlCzAPqDGF6nOmA7L42jwNASeVwxy/WI=";
  };
  "src/third_party/dart/third_party/pkg/http_parser" = fetchFromGoogle {
    owner = "dart";
    repo = "http_parser";
    rev = "eaa63304c333316acd114e3be7ed701d7d7ba32c";
    sha256 = "sha256-uTNQTobTERoAxrjaTV4acjUobPedVFUVYxADOSeEzJk=";
  };
  "src/third_party/dart/third_party/pkg/json_rpc_2" = fetchFromGoogle {
    owner = "dart";
    repo = "json_rpc_2";
    rev = "805e6536dd961d66f6b8cd46d8f3e61774f957c9";
    sha256 = "sha256-eBuTYhQsUAAaTcHZZgcR2OsiTC5HdYgp1U2BIsdr7FQ=";
  };
  "src/third_party/dart/third_party/pkg/linter" = fetchFromGoogle {
    owner = "dart";
    repo = "linter";
    rev = "1ddc70948d94f2449fec69a95e3ceb7b6b6c8348";
    sha256 = "sha256-+6n4IwXLWBLDQgdzyyHXKj0ygX+SdJd/TihmdJmcClM=";
  };
  "src/third_party/dart/third_party/pkg/logging" = fetchFromGoogle {
    owner = "dart";
    repo = "logging";
    rev = "f6979e3bc3b6e1847a08335b7eb6304e18986195";
    sha256 = "sha256-UwoXZaFP4kaUGwb6yULHoS5xfB5jx1LAx3FPky6hW0Q=";
  };
  "src/third_party/dart/third_party/pkg/markdown" = fetchFromGoogle {
    owner = "dart";
    repo = "markdown";
    rev = "e3f4bd28c9e61b522f75f291d4d6cfcfeccd83ee";
    sha256 = "sha256-qZjuCcsSHmk31OocLLTXc61GiyswZ0MAiB2yTmgwI1g=";
  };
  "src/third_party/dart/third_party/pkg/matcher" = fetchFromGoogle {
    owner = "dart";
    repo = "matcher";
    rev = "1a7fcae0d7af1604781afabe61fd35d9b404d8ed";
    sha256 = "sha256-uoHRSfUbJLfg+8ubgxQGZobUP+7l1kiXMaBxuXOeLaw=";
  };
  "src/third_party/dart/third_party/pkg/mime" = fetchFromGoogle {
    owner = "dart";
    repo = "mime";
    rev = "0a75a41445eb642674a0a271eecde78cb025ee60";
    sha256 = "sha256-bLnTFebVCH3XMLSaCv3HPSqpw9B6QYXz5OLPCraP2gY=";
  };
  "src/third_party/dart/third_party/pkg/mockito" = fetchFromGoogle {
    owner = "dart";
    repo = "mockito";
    rev = "25d25dab6b57ac710c0be0e759def7505b352ea7";
    sha256 = "sha256-K0puk17zs1Mek4ME95a4IDyfmheRXoL+kisVXmsbceI=";
  };
  "src/third_party/dart/third_party/pkg/oauth2" = fetchFromGoogle {
    owner = "dart";
    repo = "oauth2";
    rev = "199ebf15cbd5b07958438184f32e41c4447a57bf";
    sha256 = "sha256-Bc2NZhNo51lgbI7wiOw75vmSsncVnucaFNkloMRiwt0=";
  };
  "src/third_party/dart/third_party/pkg/package_config" = fetchFromGoogle {
    owner = "dart";
    repo = "package_config";
    rev = "cff98c90acc457a3b0750f0a7da0e351a35e5d0c";
    sha256 = "sha256-ISYRRt6I94Km/s49SW1aZ+KDA7xPD2ZPGKMUrHJIQ2U=";
  };
  "src/third_party/dart/third_party/pkg/path" = fetchFromGoogle {
    owner = "dart";
    repo = "path";
    rev = "7a0ed40280345b1c11df4c700c71e590738f4257";
    sha256 = "sha256-mIfYCbR7wayb6HY5ZnUvgYDlxXbFp6sSvQKqBmoKAA0=";
  };
  "src/third_party/dart/third_party/pkg/pool" = fetchFromGoogle {
    owner = "dart";
    repo = "pool";
    rev = "fa84ddd0e39f45bf3f09dcc5d6b9fbdda7820fef";
    sha256 = "sha256-rWbZzGcxfg48f76L15Io3yJYvOuVbN3dteZDb549L9c=";
  };
  "src/third_party/dart/third_party/pkg/protobuf" = fetchFromGoogle {
    owner = "dart";
    repo = "protobuf";
    rev = "2d6c6037cee6c5f683e8f38e598443f9bec74b94";
    sha256 = "sha256-+ssxEmdo13S3m/8TRK8YZcy6/zq15tpBA4BvVq70qDU=";
  };
  "src/third_party/dart/third_party/pkg/pub" = fetchFromGoogle {
    owner = "dart";
    repo = "pub";
    rev = "9bf4289d6fd5d6872a8929d6312bbd7098f3ea9c";
    sha256 = "sha256-16wX8xlPijoc4iqXwiDJgsHsWR94dhr8pIZmt6Fxft8=";
  };
  "src/third_party/dart/third_party/pkg/pub_semver" = fetchFromGoogle {
    owner = "dart";
    repo = "pub_semver";
    rev = "5c0b4bfd5ca57fe16f1319c581dc8c882e9b8cb2";
    sha256 = "sha256-CqUXyt1WFQ3dTUEJk4ucJujT5zB5Uba2bP9qr8p5l+Y=";
  };
  "src/third_party/dart/third_party/pkg/shelf" = fetchFromGoogle {
    owner = "dart";
    repo = "shelf";
    rev = "8f8f3703efd241f9cf6b18e36e0067ca74c47fd8";
    sha256 = "sha256-yI0XMdz1kYUl9d1bsyJnkF7C2sTxV8bJZTZFcTvXO+o=";
  };
  "src/third_party/dart/third_party/pkg/source_map_stack_trace" = fetchFromGoogle {
    owner = "dart";
    repo = "source_map_stack_trace";
    rev = "72dbf21a33293b2b8434d0a9751e36f9463981ac";
    sha256 = "sha256-Hz5jSV5GWYnn/3dCUBurO8tQa6alY9h5wKcdTUSiNjI=";
  };
  "src/third_party/dart/third_party/pkg/source_maps" = fetchFromGoogle {
    owner = "dart";
    repo = "source_maps";
    rev = "e93565b43a7b6b367789de8ffba969c4ebeeb317";
    sha256 = "sha256-v8+dsjkoq+8hOEVD3/teXffyS5wPsEKkuOaiPtwYtIM=";
  };
  "src/third_party/dart/third_party/pkg/source_span" = fetchFromGoogle {
    owner = "dart";
    repo = "source_span";
    rev = "24151fd80e4557a626f81f2bc0d6a2ebde172cae";
    sha256 = "sha256-XG8DPN589x/6ZEOdW/4JcEiNCSTCURNNsNbP/5Z9o7c=";
  };
  "src/third_party/dart/third_party/pkg/sse" = fetchFromGoogle {
    owner = "dart";
    repo = "sse";
    rev = "2df072848a6090d3ed67f30c69e86ec4d6b96cd6";
    sha256 = "sha256-civk5sAHGTblv8Tl+Tqud0QVeA7pv+ouJ2GPnkyG2IQ=";
  };
  "src/third_party/dart/third_party/pkg/stack_trace" = fetchFromGoogle {
    owner = "dart";
    repo = "stack_trace";
    rev = "17f09c2c6845bb31c7c385acecce5befb8527a13";
    sha256 = "sha256-jemHg3njJcTHuuszzPBtCfXyL65sH9k0EK9Z3dOLsjY=";
  };
  "src/third_party/dart/third_party/pkg/stream_channel" = fetchFromGoogle {
    owner = "dart";
    repo = "stream_channel";
    rev = "8e0d7ef1f4a3fb97fbd82e11cd539093f58511f3";
    sha256 = "sha256-l0rk+4EpKnZaCXQuoy2uPSvNxICIYUDDyZmi3lBJtOs=";
  };
  "src/third_party/dart/third_party/pkg/string_scanner" = fetchFromGoogle {
    owner = "dart";
    repo = "string_scanner";
    rev = "c637deb8d998b72a5807afbd06aba8370db725c0";
    sha256 = "sha256-lfsAKmkZt0PEgFUNRvDRDfjRgUn9fK3zsurSBqjujuI=";
  };
  "src/third_party/dart/third_party/pkg/term_glyph" = fetchFromGoogle {
    owner = "dart";
    repo = "term_glyph";
    rev = "741efdedf9da62ee66a06c295d36fa28f8780e24";
    sha256 = "sha256-U4EzZ2FPUAhLF8usNjXtHLgIEeJHDZRiqtC/0x3j1c0=";
  };
  "src/third_party/dart/third_party/pkg/test" = fetchFromGoogle {
    owner = "dart";
    repo = "test";
    rev = "fb4ccaf6c68fcc1d208c5c53a52d8e0e718bdffe";
    sha256 = "sha256-HhY37pKFYUfdLnYOgHmSqV0FNM0LlCU+zskf1ZNIQ0I=";
  };
  "src/third_party/dart/third_party/pkg/test_reflective_loader" = fetchFromGoogle {
    owner = "dart";
    repo = "test_reflective_loader";
    rev = "8d0de01bbe852fea1f8e33aba907abcba50a8a1e";
    sha256 = "sha256-LNjn7LdMDYWBogqlwx8F+a0MGPCBYo8yTo4cPdJm7cI=";
  };
  "src/third_party/dart/third_party/pkg/typed_data" = fetchFromGoogle {
    owner = "dart";
    repo = "typed_data";
    rev = "bb10b64f9a56b8fb49307d4465474bf1c1309f6d";
    sha256 = "sha256-0BhVJgeQdwdRebRofC9/a6xb9h93UL+193qkYSLtWbI=";
  };
  "src/third_party/dart/third_party/pkg/usage" = fetchFromGoogle {
    owner = "dart";
    repo = "usage";
    rev = "1d3c31e780af665fb796a27898a441fcb7d263db";
    sha256 = "sha256-JbI4feydhb/k5jycjkusp17QrlcNaUybMnsD/ZfHFgg=";
  };
  "src/third_party/dart/third_party/pkg/watcher" = fetchFromGoogle {
    owner = "dart";
    repo = "watcher";
    rev = "e00c0ea769e32821d91c0880da8eb736839a6e6d";
    sha256 = "sha256-AkYKFuLdsrd0ZE6lwCCRBXRzOnYEw7+0GVPAaUbzPV4=";
  };
  "src/third_party/dart/third_party/pkg/web_socket_channel" = fetchFromGoogle {
    owner = "dart";
    repo = "web_socket_channel";
    rev = "99dbdc5769e19b9eeaf69449a59079153c6a8b1f";
    sha256 = "sha256-wlcjbxiVca8D6RXvWfkMl8gt0Pk0NbV5E2zkHJga6lE=";
  };
  "src/third_party/dart/third_party/pkg/webdev" = fetchFromGoogle {
    owner = "dart";
    repo = "webdev";
    rev = "9c4428472b04f50748ea4871829897cff43455a3";
    sha256 = "sha256-Mtcvr5Ry2hkdvkrv/jNoIhFbj6xWS2NQcTH3fOXhGcE=";
  };
  "src/third_party/dart/third_party/pkg/webkit_inspection_protocol" = fetchFromGoogle {
    owner = "dart";
    repo = "external/github.com/google/webkit_inspection_protocol.dart";
    rev = "57522d6b29d94903b765c757079d906555d5a171";
    sha256 = "sha256-7JsLW47Aa8GOXexn9IbARJ459KmWM5S8lSiNUTT0HuU=";
  };
  "src/third_party/dart/third_party/pkg/yaml" = fetchFromGoogle {
    owner = "dart";
    repo = "yaml";
    rev = "fda5b15692ccfa0feb7793a27fe3829b3d0f77fa";
    sha256 = "sha256-fqJrLLuewcVvNP31H7NlbfpVHJveJYBKrqY3vG2Ux0I=";
  };
  "src/third_party/dart/third_party/pkg/yaml_edit" = fetchFromGoogle {
    owner = "dart";
    repo = "yaml_edit";
    rev = "01589b3ce447b03aed991db49f1ec6445ad5476d";
    sha256 = "sha256-MSEBs2oqirJXibf/dsMGpCiZyN/44WJc1eR0ispr9qA=";
  };
  "src/third_party/expat" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/libexpat/libexpat";
    rev = "a28238bdeebc087071777001245df1876a11f5ee";
    sha256 = "sha256-22NUjDu0P+2XGug+iDm/jr2rO/RYIinZxU+PIM+TQTI=";
  };
  "src/third_party/fontconfig" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/fontconfig";
    rev = "81c83d510ae3aa75589435ce32a5de05139aacb0";
    sha256 = "sha256-hZd3ORqLagQrhcAJsyFcskmC1fj+Ex7NxL4ysM6L2sQ=";
  };
  "src/third_party/fontconfig/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/fontconfig";
    rev = "c336b8471877371f0190ba06f7547c54e2b890ba";
    sha256 = "sha256-AOWpx2plU4CdaJUsXvJHzmbBlfZENXFonW2iVaq10k4=";
  };
  "src/third_party/flatbuffers" = fetchFromGitHub {
    owner = "google";
    repo = "flatbuffers";
    rev = "0a80646371179f8a7a5c1f42c31ee1d44dcf6709";
    sha256 = "sha256-6t3bn5SpDh9y5c6ziWKXBPI8UhQWLDMcX66zjBLA+Gs=";
    leaveDotGit = true;
  };
  "src/third_party/freetype2" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/freetype2";
    rev = "3bea2761290a1cbe7d8f75c1c5a7ad727f826a66";
    sha256 = "sha256-7fnfOXg+pY8lnJ1CMc5XPdt/Dt5G3lW43Z2VR4hJq2o=";
  };
  "src/third_party/fuchsia-vulkan" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/Vulkan-Headers";
    rev = "32640ad82ef648768c706c9bf828b77123a09bc2";
    sha256 = "sha256-7RG6vUDuaRbKLZyQ7E4Om4CLYAhlHK7f2hB8shab8+E=";
  };
  "src/third_party/glfw" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/glfw";
    rev = "78e6a0063d27ed44c2c4805606309744f6fb29fc";
    sha256 = "sha256-1/1Ku6O+jDMOuAinzUWZeSB9ysJ6lM1p96jAw/4SJBQ=";
  };
  "src/third_party/googletest" = fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    rev = "054a986a8513149e8374fc669a5fe40117ca6b41";
    sha256 = "sha256-y+BbjhvxJzTBG4UdFYFtXbiHbDudlrrUVnkBJhOtu18=";
    leaveDotGit = true;
  };
  "src/third_party/gtest-parallel" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/google/gtest-parallel";
    rev = "38191e2733d7cbaeaef6a3f1a942ddeb38a2ad14";
    sha256 = "sha256-wJMtZ4JzMK1CepixQFy32iPjJxb3xBb3QO97RTkKX0s=";
  };
  "src/third_party/harfbuzz" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/harfbuzz";
    rev = "d40d15e994ed60d32bcfc9ab87004dfb028dfbd6";
    sha256 = "sha256-0XZBnNfwGLfZPJJbji9+A/hY456MiSPbZzi7jYS+PJ8=";
  };
  "src/third_party/icu" = fetchFromGoogle {
    owner = "chromium";
    repo = "chromium/deps/icu";
    rev = "12de966fcbe1d1a48dba310aee63807856ffeee8";
    sha256 = "sha256-3cOC2uKUimVE+qgFFN/71qUF/LYyNogYECE+506HqVc=";
  };
  "src/third_party/imgui" = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    rev = "29d462ebce0275345a6ce4621d8fff0ded57c9e5";
    sha256 = "sha256-KqtVInZCO3vjnStavaZEhDUwGfa4EVGF+VeMjUuPixI=";
    leaveDotGit = true;
  };
  "src/third_party/inja" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/inja";
    rev = "88bd6112575a80d004e551c98cf956f88ff4d445";
    sha256 = "sha256-t4HfJFqPAXOH+B+dlxFN5VGib010z2a0IH8GPyhYy4Q=";
  };
  "src/third_party/khronos" = fetchFromGoogle {
    owner = "chromium";
    repo = "chromium/src/third_party/khronos";
    rev = "676d544d2b8f48903b7da9fceffaa534a5613978";
    sha256 = "sha256-jUq8VBd2BKrKnODpYKuog81ZTJXxFPdbUBnqrV8Bazc=";
  };
  "src/third_party/libcxx" = fetchFromGoogle {
    owner = "llvm";
    repo = "libcxx";
    rev = "7524ef50093a376f334a62a7e5cebf5d238d4c99";
    sha256 = "sha256-9KcbJThHyjbfWPAcOWC3jF4ey1hAibkQSHZbcqte7AM=";
  };
  "src/third_party/libcxxabi" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/libcxxabi";
    rev = "74d1e602c76350f0760bf6907910e4f3a4fccffe";
    sha256 = "sha256-BYVUgHWHd47QbFCAw38WDDEb6Iy4x5eE46PgEinWtvA=";
  };
  "src/third_party/libjpeg-turbo" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/libjpeg-turbo";
    rev = "0fb821f3b2e570b2783a94ccd9a2fb1f4916ae9f";
    sha256 = "sha256-uPgkA6lUwgJuByyJNHRzbVYR2d9dRMOOnfdGde1H2Sk=";
  };
  "src/third_party/libpng" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/libpng";
    rev = "134cf139cb24d802ee6ad5fc51bccff3221c2b49";
    sha256 = "sha256-21okOFoSWTaNawPq9duz+ZpNy86Yio3qNaqyo7lKN18=";
  };
  "src/third_party/libtess2" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/libtess2";
    rev = "fc52516467dfa124bdd967c15c7cf9faf02a34ca";
    sha256 = "sha256-Ol9JLLHs7OmIILO7O6J1JAnu8iLzY2mZ60wpn6Io8C4=";
  };
  "src/third_party/libwebp" = fetchFromGoogle {
    owner = "chromium";
    repo = "webm/libwebp";
    rev = "7dfde712a477e420968732161539011e0fd446cf";
    sha256 = "sha256-NY7tbiVvXm9Ue1jCkRXwukV9Eb7Z0ktHQNUwMkX/kG4=";
  };
  "src/third_party/libxml" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/libxml";
    rev = "a143e452b5fc7d872813eeadc8db421694058098";
    sha256 = "sha256-Ga0MFoI3J4of0vpycmxzfgSvJ7CM3f+K3ICCEF2+1dQ=";
  };
  "src/third_party/ocmock" = fetchFromGitHub {
    owner = "erikdoe";
    repo = "ocmock";
    rev = "c4ec0e3a7a9f56cfdbd0aa01f4f97bb4b75c5ef8";
    sha256 = "sha256-CQ2qJEH3R9Hp9dXyWz3REerxOa6yoIlpQnQ0d7g4kNw=";
    leaveDotGit = true;
  };
  "src/third_party/pyyaml" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/pyyaml";
    rev = "25e97546488eee166b1abb229a27856cecd8b7ac";
    sha256 = "sha256-0D8EqyEkXuWgszC5N3iiQ+OdpZYUMqCdHDgsFfD/Nog=";
  };
  "src/third_party/pkg/archive" = fetchFromGitHub {
    owner = "brendan-duncan";
    repo = "archive";
    rev = "9de7a0544457c6aba755ccb65abb41b0dc1db70d";
    sha256 = "sha256-+Be9X/TUj157eKG6DtZ4SC2tR4CuEWkB3BsTdNzEcDU=";
    leaveDotGit = true;
  };
  "src/third_party/pkg/equatable" = fetchFromGitHub {
    owner = "felangel";
    repo = "equatable";
    rev = "0ba67c72db8bed75877fc1caafa74112ee0bd921";
    sha256 = "sha256-A4qLZHMglprPnsAh11iM5r9B5A7phF5Z2OKtmCVN9hY=";
    leaveDotGit = true;
  };
  "src/third_party/pkg/file" = fetchFromGitHub {
    owner = "google";
    repo = "file.dart";
    rev = "427bb20ccc852425d67f2880da2a9b4707c266b4";
    sha256 = "sha256-U3Db3BuYmAeLUtT8spymbvAjNFEGCkwTMpu4QzicsKw=";
    leaveDotGit = true;
  };
  "src/third_party/pkg/flutter_packages" = fetchFromGitHub {
    owner = "flutter";
    repo = "packages";
    rev = "a19eca7fe2660c71acf5928a275deda1da318c50";
    sha256 = "sha256-2KrDOBlxzztv2IKDirzliz5E//fpNxMXsZJ1eGYh8aM=";
    leaveDotGit = true;
  };
  "src/third_party/pkg/gcloud" = fetchFromGitHub {
    owner = "dart-lang";
    repo = "gcloud";
    rev = "92a33a9d95ea94a4354b052a28b98088d660e0e7";
    sha256 = "sha256-OpPtkEzfCQD0nGnz0wvkppskTLrpzfpAwswXl+Y8Aws=";
    leaveDotGit = true;
  };
  "src/third_party/pkg/googleapis" = fetchFromGitHub {
    owner = "google";
    repo = "googleapis.dart";
    rev = "07f01b7aa6985e4cafd0fd4b98724841bc9e85a1";
    sha256 = "sha256-pglQY6C0pT80jzWoDeWMvEjI1DTiQ9nLR7n4BvIfLrc=";
    leaveDotGit = true;
  };
  "src/third_party/pkg/platform" = fetchFromGitHub {
    owner = "google";
    repo = "platform.dart";
    rev = "1ffad63428bbd1b3ecaa15926bacfb724023648c";
    sha256 = "sha256-ZIi3fKw1LLsxXRpLbDAp8viz9XQZL6SFq8RkzgCQ/L4=";
    leaveDotGit = true;
  };
  "src/third_party/pkg/process" = fetchFromGitHub {
    owner = "google";
    repo = "process.dart";
    rev = "0c9aeac86dcc4e3a6cf760b76fed507107e244d5";
    sha256 = "sha256-KDKDMNx/sQ/YWuBEY5Z4Tqb8K3pfl3N1qav8Bwxekws=";
    leaveDotGit = true;
  };
  "src/third_party/pkg/process_runner" = fetchFromGitHub {
    owner = "google";
    repo = "process_runner";
    rev = "d632ea0bfd814d779fcc53a361ed33eaf3620a0b";
    sha256 = "sha256-e/IOJnEuZi+pfl0+2wuX2Pz7XR43nDp6fXvpN49wdFk=";
    leaveDotGit = true;
  };
  "src/third_party/pkg/quiver" = fetchFromGitHub {
    owner = "google";
    repo = "quiver-dart";
    rev = "66f473cca1332496e34a783ba4527b04388fd561";
    sha256 = "sha256-+oihqyW/yL/xietUNYSOmS5jY+FodPtPrj6OnfobxPk=";
    leaveDotGit = true;
  };
  "src/third_party/pkg/vector_math" = fetchFromGitHub {
    owner = "google";
    repo = "vector_math.dart";
    rev = "0a5fd95449083d404df9768bc1b321b88a7d2eef";
    sha256 = "sha256-CQ2qJEH3R9Hp9dXyWz3REerxOa6yoIlpQnQ0d7g4kNw=";
    leaveDotGit = true;
  };
  "src/third_party/rapidjson" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/rapidjson";
    rev = "ef3564c5c8824989393b87df25355baf35ff544b";
    sha256 = "sha256-FX3GDyXWB2ZpPDLzD+SkiAjSYxoIWp4VtXdVUahiv3c=";
  };
  "src/third_party/root_certificates" = fetchFromGoogle {
    owner = "dart";
    repo = "root_certificates";
    rev = "692f6d6488af68e0121317a9c2c9eb393eb0ee50";
    sha256 = "sha256-Jpcjt4MoPiIYUlpJv6C1j0ZjLolJ1NWFxIBhUAzlsIs=";
  };
  "src/third_party/shaderc" = fetchFromGitHub {
    owner = "google";
    repo = "shaderc";
    rev = "948660cccfbbc303d2590c7f44a4cee40b66fdd6";
    sha256 = "sha256-uhdN0QgzFsYlwbbgYOSMztyfYI8u8QbQYXwJA/jysEA=";
    leaveDotGit = true;
  };
  "src/third_party/skia" = fetchFromGoogle {
    owner = "skia";
    repo = "skia";
    rev = "936433124f938c06d5b1609d534cd9b693edd71c";
    sha256 = "sha256-2aDPXJ2Egnj2S28GOSIYTCfjeHPQWed1U9jeZmJYJmE=";
  };
  "src/third_party/sqlite" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/sqlite";
    rev = "0f61bd2023ba94423b4e4c8cfb1a23de1fe6a21c";
    sha256 = "sha256-zToltrmle9jourBpcZfyBgaNRBtn/OdhzOslgAx0Zs0=";
  };
  "src/third_party/swiftshader" = fetchFromGoogle {
    owner = "swiftshader";
    repo = "SwiftShader";
    rev = "bea8d2471bd912220ba59032e0738f3364632657";
    sha256 = "sha256-FqeEcyLBkqiN+cBqUVvdERshMaK4LleovIFYPo/dWjs=";
  };
  "src/third_party/vulkan-deps" = fetchFromGoogle {
    owner = "chromium";
    repo = "vulkan-deps";
    rev = "23b710f1a0b3c44d51035c6400a554415f95d9c6";
    sha256 = "sha256-it837kYvutF+iq3Azs7uWz/BHI8xbGuAeHfbpTcUybQ=";
  };
  "src/third_party/vulkan-deps/glslang/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/glslang";
    rev = "316f12ac1d4f2fc9517ee1a18b2d710561df228c";
    sha256 = "sha256-a8g/lChZFh70IG173prkmKR7xinclSfrXU2j0JrCtQk=";
  };
  "src/third_party/vulkan-deps/spirv-cross/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/SPIRV-Cross";
    rev = "50b4d5389b6a06f86fb63a2848e1a7da6d9755ca";
    sha256 = "sha256-0XgIUGq7R/PnesQ0e7Uky9MpOPp6eKwpyCcJWFOx1Hc=";
  };
  "src/third_party/vulkan-deps/spirv-headers/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/SPIRV-Headers";
    rev = "b2a156e1c0434bc8c99aaebba1c7be98be7ac580";
    sha256 = "sha256-qaHyjxX+8Oiw1mn81qIG8X6H8SlZ4rq1Gz7wSmmAqy0=";
  };
  "src/third_party/vulkan-deps/spirv-tools/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/SPIRV-Tools";
    rev = "b930e734ea198b7aabbbf04ee1562cf6f57962f0";
    sha256 = "sha256-OfpxyF7qgWkcthAUOnafIVMxQ8FWDDQ/MMSn+LSIIZQ=";
  };
  "src/third_party/vulkan-deps/vulkan-headers/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/Vulkan-Headers";
    rev = "245d25ce8c3337919dc7916d0e62e31a0d8748ab";
    sha256 = "sha256-/no/0rSfD31AEniRpbCSpQ72AsSAbttvFxllFc+9avY=";
  };
  "src/third_party/vulkan-deps/vulkan-loader/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/Vulkan-Loader";
    rev = "5437a0854fb6b664e2c48c0b8e7b157ac23fe741";
    sha256 = "sha256-mS4l+YHECl/UHVnlPkBbohbOrAuz+TToKMjQencH7eo=";
  };
  "src/third_party/vulkan-deps/vulkan-tools/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/Vulkan-Tools";
    rev = "dd7e8d2fbbdaca099e9ada77fec178e12a6b37d5";
    sha256 = "sha256-zu3XxnwxmawJl1XAELKtfG7cvUTjHSm/J5l1JJzHsc4=";
  };
  "src/third_party/vulkan-deps/vulkan-validation-layers/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/Vulkan-ValidationLayers";
    rev = "c97b4d72932091591713277f4b3e5b70f89736a2";
    sha256 = "sha256-Jpto4A7narcKWXc1G+eZs/GCdKB5nNJpSzqHlc8KNEc=";
  };
  "src/third_party/vulkan_memory_allocator" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator";
    rev = "7de5cc00de50e71a3aab22dea52fbb7ff4efceb6";
    sha256 = "sha256-2xZzE3BPHmhy447r0zMY5eFY5bgWeJm1NKeVL2+dWl0=";
  };
  "src/third_party/wuffs" = fetchFromGoogle {
    owner = "skia";
    repo = "external/github.com/google/wuffs-mirror-release-c";
    rev = "600cd96cf47788ee3a74b40a6028b035c9fd6a61";
    sha256 = "sha256-kguW6k83LP0rHvn6GSpZFPRVVBkSNk0/kh1B4RZHHlY=";
  };
  "src/third_party/yapf" = fetchFromGitHub {
    owner = "google";
    repo = "yapf";
    rev = "212c5b5ad8e172d2d914ae454c121c89cccbcb35";
    sha256 = "sha256-+buQydUJEUGzwTTaaJ4MnXBb2eIp5E23gv4J+MMX9sU=";
    leaveDotGit = true;
  };
  "src/third_party/zlib" = fetchFromGoogle {
    owner = "chromium";
    repo = "chromium/src/third_party/zlib";
    rev = "27c2f474b71d0d20764f86f60ef8b00da1a16cda";
    sha256 = "sha256-7pOLvK5eDSSYltbTF8oDEUW4vJZF5SoJTqZAV8vr1c0=";
  };
}
