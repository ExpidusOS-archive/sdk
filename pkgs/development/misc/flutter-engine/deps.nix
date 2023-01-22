{ lib, fetchgit, fetchcipd, fetchFromGitHub }@args:
with lib;
let
  fetchFromGitHub = { owner, repo, fetchSubmodules ? false, rev ? "HEAD", sha256 ? fakeHash }: args.fetchFromGitHub {
    inherit owner repo fetchSubmodules rev sha256;
  };

  fetchFromGoogle = { owner, repo, fetchSubmodules ? false, rev ? "HEAD", sha256 ? fakeHash }: fetchgit {
    url = "https://${owner}.googlesource.com/${repo}.git";
    inherit rev sha256 fetchSubmodules;
  };
in {
  src = fetchFromGitHub {
    owner = "flutter";
    repo = "buildroot";
    rev = "6af51ff4b86270cc61517bff3fff5c3bb11492e1";
    sha256 = "sha256-Ixyv/sKvpU+1EbZl0WMn6Xkwc7OmVSBCOnF4D+GmTOg=";
  };
  "src/third_party/abseil-cpp" = fetchFromGoogle {
    owner = "chromium";
    repo = "chromium/src/third_party/abseil-cpp";
    rev = "2d8c1340f0350828f1287c4eaeebefcf317bcfc9";
    sha256 = "sha256-VXwL0tbx2Sp6n73jmA4m/lOl7LGP8N/OQ53tPIN6mZE=";
  };
  "src/third_party/angle" = fetchFromGoogle {
    owner = "chromium";
    repo = "angle/angle";
    rev = "3faaded8234b31dea24c929e40e33089a34a9aa5";
    sha256 = "sha256-jcLIjP0Zcgz2obzTCo8uf6Y8oosBFkYFzfcMKhi9UcY=";
  };
  "src/third_party/benchmark" = fetchFromGitHub {
    owner = "google";
    repo = "benchmark";
    rev = "431abd149fd76a072f821913c0340137cc755f36";
    sha256 = "sha256-3qCucsZYSfmSsI+U3oMmvSxr1EogtTjfkf6UcT9QhQM=";
  };
  "src/third_party/boringssl" = fetchFromGitHub {
    owner = "dart-lang";
    repo = "boringssl_gen";
    rev = "ced85ef0a00bbca77ce5a91261a5f2ae61b1e62f";
    sha256 = "sha256-QraDt6PpzNw8kjQ/AwZn/WpCSSlG/ATigT6mwaBO3qc=";
  };
  "src/third_party/boringssl/src" = fetchFromGoogle {
    owner = "boringssl";
    repo = "boringssl";
    rev = "87f316d7748268eb56f2dc147bd593254ae93198";
    sha256 = "sha256-WqRrQwC1uQwwHK1L3GkHYmCtnR8AMmaSQB8Cfl8HWSk=";
  };
  "src/third_party/colorama/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/colorama";
    rev = "799604a1041e9b3bc5d2789ecbd7e8db2e18e6b8";
    sha256 = "sha256-6K0Kq7USa8VtM22YecggZ6tt7vdp86gtWO1jJmBOPlo=";
  };
  "src/third_party/dart" = fetchFromGoogle {
    owner = "dart";
    repo = "sdk";
    rev = "b6592742d9f1a82af319f46eda3d59a61e89b91b";
    sha256 = "sha256-L73kGFLNPIv3c9z2nmOkB9zilZpR9gVKw6pHTu+y2TM=";
  };
  "src/third_party/dart/third_party/pkg/args" = fetchFromGoogle {
    owner = "dart";
    repo = "args";
    rev = "73e8d3b55cbedc9765f8e266f3422d8914f8e62a";
    sha256 = "sha256-sCfqZKYHJsXIiDG0Yaolkx3ON2t4sRCOMdglc7mPvG8=";
  };
  "src/third_party/dart/third_party/pkg/async" = fetchFromGoogle {
    owner = "dart";
    repo = "async";
    rev = "f3ed5f690e2ec9dbe1bfc5184705575b4f6480e5";
    sha256 = "sha256-xK8UudpwYnmk/QoOK7jxf0lFv5pdp5F4hJl1XlR+tlQ=";
  };
  "src/third_party/dart/third_party/pkg/bazel_worker" = fetchFromGoogle {
    owner = "dart";
    repo = "bazel_worker";
    rev = "9710de6c9c70b1b583183db9d9721ba64e5a16fe";
    sha256 = "sha256-Rzk0dTFxO0Ny7mJjcGXCH74OPHK4acAycQIkVtkc9+I=";
  };
  "src/third_party/dart/third_party/pkg/boolean_selector" = fetchFromGoogle {
    owner = "dart";
    repo = "boolean_selector";
    rev = "1d3565e2651d16566bb556955b96ea75018cbd0c";
    sha256 = "sha256-EJX91u8hx/0SHyk2vUKpZIr4Ctu8ykbHBlVL9xoqmWc=";
  };
  "src/third_party/dart/third_party/pkg/browser_launcher" = fetchFromGoogle {
    owner = "dart";
    repo = "browser_launcher";
    rev = "981ca8847dd2b0fe022f9e742045cfb8f214d35f";
    sha256 = "sha256-X2GIssLYf1rYLVQzoVWkjjOLZwovcR6YPMjzy0lAbis=";
  };
  "src/third_party/dart/third_party/pkg/cli_util" = fetchFromGoogle {
    owner = "dart";
    repo = "cli_util";
    rev = "b0adbba89442b2ea6fef39c7a82fe79cb31e1168";
    sha256 = "sha256-w6yHsFcrfjfDTz/RRTGB5/n7yh1fzpAP6fR025DrqRY=";
  };
  "src/third_party/dart/third_party/pkg/clock" = fetchFromGoogle {
    owner = "dart";
    repo = "clock";
    rev = "2507a228773c5e877fc9e3330080b234aad965c0";
    sha256 = "sha256-EOjUaStEJwez5L1W7mBTzzudXW46d+utZmarkLcYpKM=";
  };
  "src/third_party/dart/third_party/pkg/collection" = fetchFromGoogle {
    owner = "dart";
    repo = "collection";
    rev = "414ffa1bc8ba18bd608bbf916d95715311d89ac1";
    sha256 = "sha256-hcx97ei4GVzlayGaaCdiOjOG75gkCfcPsFXdE2jswE8=";
  };
  "src/third_party/dart/third_party/pkg/convert" = fetchFromGoogle {
    owner = "dart";
    repo = "convert";
    rev = "7145da14f9cd730e80fb4c6a10108fcfd205e8e7";
    sha256 = "sha256-Afikg5SzXx0QdAnLImVNGPjFWe7nzPTsv1iDBg2L2RQ=";
  };
  "src/third_party/dart/third_party/pkg/crypto" = fetchFromGoogle {
    owner = "dart";
    repo = "crypto";
    rev = "223e0a62c0f762fd2b510f753861445b52e14fc3";
    sha256 = "sha256-GPb0rtwFTey10pyJgmqRY34wHak+Jk0zPnog6MyTnac=";
  };
  "src/third_party/dart/third_party/pkg/csslib" = fetchFromGoogle {
    owner = "dart";
    repo = "csslib";
    rev = "ba2eb2d80530eedefadaade338a09c2dd60410f3";
    sha256 = "sha256-rSp1NIY0JISOTyG3vtp8+gM4tZ52xy6Ph3O7yUHEKY4=";
  };
  "src/third_party/dart/third_party/pkg/dart_style" = fetchFromGoogle {
    owner = "dart";
    repo = "dart_style";
    rev = "d7b73536a8079331c888b7da539b80e6825270ea";
    sha256 = "sha256-SpaAMrrzZV9AzrgzXMKBj8iMWQ0Z4G9NQ6JbcMh2pkI=";
  };
  "src/third_party/dart/third_party/pkg/dartdoc" = fetchFromGoogle {
    owner = "dart";
    repo = "dartdoc";
    rev = "adc5a45ddafb57e3a600ee7d9e88dc81061d1410";
    sha256 = "sha256-5t2ZZwhOOOuiLpkzQ1RKGpy/KfNKRn6I0xdIAkT2wjk=";
  };
  "src/third_party/dart/third_party/pkg/ffi" = fetchFromGoogle {
    owner = "dart";
    repo = "ffi";
    rev = "18b2b549d55009ff594600b04705ff6161681e07";
    sha256 = "sha256-gmwCdOIrl7B8nDscGgENWcV8L8eapfVRMIXt5KTTw3c=";
  };
  "src/third_party/dart/third_party/pkg/file" = fetchFromGoogle {
    owner = "dart";
    repo = "external/github.com/google/file.dart";
    rev = "0132eeedea2933513bf230513a766a8baeab0c4f";
    sha256 = "sha256-hrLIit8rpy6A5JgYMGqAJ05KZ1TuDYWVUDvS+xoaqT8=";
  };
  "src/third_party/dart/third_party/pkg/fixnum" = fetchFromGoogle {
    owner = "dart";
    repo = "fixnum";
    rev = "164712f6547cdfb2709b752188186baf31fd1730";
    sha256 = "sha256-V/IwnlPdjLXmC4JAxMiDIYnwDeHU7iouxrOAF4ztkQk=";
  };
  "src/third_party/dart/third_party/pkg/glob" = fetchFromGoogle {
    owner = "dart";
    repo = "glob";
    rev = "1d51fcc172e5adfbae6e82c3f8f119774cb2fca2";
    sha256 = "sha256-9Vii7gM5lxUIRjBCXniQu3uIY2MWANVPH4xwmzePfGU=";
  };
  "src/third_party/dart/third_party/pkg/html" = fetchFromGoogle {
    owner = "dart";
    repo = "html";
    rev = "8243e967caad9932c13971af3b2a7c8f028383d5";
    sha256 = "sha256-PBIv2vURQ8octneT+fN5PJulDhO+rCaAt8u4V1s/PJQ=";
  };
  "src/third_party/dart/third_party/pkg/http" = fetchFromGoogle {
    owner = "dart";
    repo = "http";
    rev = "843c5ecb1ea2233ba7b7049833b5801b149fba86";
    sha256 = "sha256-IDq1qkLdKzUIQFKXojS8eqrjI2nCh/CBAqNFB4q4Mu8=";
  };
  "src/third_party/dart/third_party/pkg/http_multi_server" = fetchFromGoogle {
    owner = "dart";
    repo = "http_multi_server";
    rev = "20bf079c8955d1250a45afb9cb096472a724a551";
    sha256 = "sha256-ymD+hJs0m4Z8H8q3DMkGl7SjnkZvIzDv4ag21ss5+6s=";
  };
  "src/third_party/dart/third_party/pkg/http_parser" = fetchFromGoogle {
    owner = "dart";
    repo = "http_parser";
    rev = "eaa63304c333316acd114e3be7ed701d7d7ba32c";
    sha256 = "sha256-SOdIExxD+fLxtFR4Rp31zH5+weseFS8wVmJ78lFlLlw=";
  };
  "src/third_party/dart/third_party/pkg/json_rpc_2" = fetchFromGoogle {
    owner = "dart";
    repo = "json_rpc_2";
    rev = "805e6536dd961d66f6b8cd46d8f3e61774f957c9";
    sha256 = "sha256-o1OGAFEOnUcSRr6A+J/8vbUA8Yji2j4tusAxaonTNIw=";
  };
  "src/third_party/dart/third_party/pkg/linter" = fetchFromGoogle {
    owner = "dart";
    repo = "linter";
    rev = "1ddc70948d94f2449fec69a95e3ceb7b6b6c8348";
    sha256 = "sha256-FAOjdfLQc+DjAVeTTVxeAXgocB1M7V6F06OS2WgF9Q4=";
  };
  "src/third_party/dart/third_party/pkg/logging" = fetchFromGoogle {
    owner = "dart";
    repo = "logging";
    rev = "f6979e3bc3b6e1847a08335b7eb6304e18986195";
    sha256 = "sha256-8hwBCONprTpv1wVLYGmA4SYMbiegRzLtP/qujiRW2XY=";
  };
  "src/third_party/dart/third_party/pkg/markdown" = fetchFromGoogle {
    owner = "dart";
    repo = "markdown";
    rev = "e3f4bd28c9e61b522f75f291d4d6cfcfeccd83ee";
    sha256 = "sha256-w0oQ0IMd6S9D9l5rguZ3IyIamNXAjp9Yb5stRTF6CaY=";
  };
  "src/third_party/dart/third_party/pkg/matcher" = fetchFromGoogle {
    owner = "dart";
    repo = "matcher";
    rev = "1a7fcae0d7af1604781afabe61fd35d9b404d8ed";
    sha256 = "sha256-HPsufbuGwIPNTNG+Y66+2x5c8PZ6HpTsChoSgapYZ1M=";
  };
  "src/third_party/dart/third_party/pkg/mime" = fetchFromGoogle {
    owner = "dart";
    repo = "mime";
    rev = "0a75a41445eb642674a0a271eecde78cb025ee60";
    sha256 = "sha256-J9HoM2uDwDFNrPV30VkCXsYn/EJObYsRv30jAzynmow=";
  };
  "src/third_party/dart/third_party/pkg/mockito" = fetchFromGoogle {
    owner = "dart";
    repo = "mockito";
    rev = "25d25dab6b57ac710c0be0e759def7505b352ea7";
    sha256 = "sha256-tFOn3/2LfcCZiH4I/uezQFKxw01oDwhR331veXfw60Q=";
  };
  "src/third_party/dart/third_party/pkg/oauth2" = fetchFromGoogle {
    owner = "dart";
    repo = "oauth2";
    rev = "199ebf15cbd5b07958438184f32e41c4447a57bf";
    sha256 = "sha256-ihdX79tXQmfxFizO+8LcHHUsNB3r7KJGDDsCeoH2/S0=";
  };
  "src/third_party/dart/third_party/pkg/package_config" = fetchFromGoogle {
    owner = "dart";
    repo = "package_config";
    rev = "cff98c90acc457a3b0750f0a7da0e351a35e5d0c";
    sha256 = "sha256-Zo8K8GcuCJNOylv5guHm2iNa4O5tGhVYO/3fwVldKno=";
  };
  "src/third_party/dart/third_party/pkg/path" = fetchFromGoogle {
    owner = "dart";
    repo = "path";
    rev = "7a0ed40280345b1c11df4c700c71e590738f4257";
    sha256 = "sha256-FcoKxb1QA/+jccycjKpps8x1jkisdDmwdRdIot4u8Ig=";
  };
  "src/third_party/dart/third_party/pkg/pool" = fetchFromGoogle {
    owner = "dart";
    repo = "pool";
    rev = "fa84ddd0e39f45bf3f09dcc5d6b9fbdda7820fef";
    sha256 = "sha256-hxSNU/L1OJrufQ/BoyLn+yhIJBTibKDrgDnySpkp+Co=";
  };
  "src/third_party/dart/third_party/pkg/protobuf" = fetchFromGoogle {
    owner = "dart";
    repo = "protobuf";
    rev = "2d6c6037cee6c5f683e8f38e598443f9bec74b94";
    sha256 = "sha256-u6NkrRmdiEWb1IEmAECpHH3qTXycTrIuhRGxdHVVk+Q=";
  };
  "src/third_party/dart/third_party/pkg/pub" = fetchFromGoogle {
    owner = "dart";
    repo = "pub";
    rev = "9bf4289d6fd5d6872a8929d6312bbd7098f3ea9c";
    sha256 = "sha256-ZKJxDUyAndlit2cLUibhwP1F8IHeA8NVnhQ/OkQoQOA=";
  };
  "src/third_party/dart/third_party/pkg/pub_semver" = fetchFromGoogle {
    owner = "dart";
    repo = "pub_semver";
    rev = "5c0b4bfd5ca57fe16f1319c581dc8c882e9b8cb2";
    sha256 = "sha256-dT73slarEdk+P4SosdjULPwwBI/AAXwjpYI1v3Ui6n4=";
  };
  "src/third_party/dart/third_party/pkg/shelf" = fetchFromGoogle {
    owner = "dart";
    repo = "shelf";
    rev = "8f8f3703efd241f9cf6b18e36e0067ca74c47fd8";
    sha256 = "sha256-7DwSqlSyblYUm+4LvWfrnu7IozlNLBnejih9ZRaggzo=";
  };
  "src/third_party/dart/third_party/pkg/source_map_stack_trace" = fetchFromGoogle {
    owner = "dart";
    repo = "source_map_stack_trace";
    rev = "72dbf21a33293b2b8434d0a9751e36f9463981ac";
    sha256 = "sha256-MdeUpa8CrcoIjWKqxhTi03hWzPBEzGKqOjeAaWwZb5M=";
  };
  "src/third_party/dart/third_party/pkg/source_maps" = fetchFromGoogle {
    owner = "dart";
    repo = "source_maps";
    rev = "e93565b43a7b6b367789de8ffba969c4ebeeb317";
    sha256 = "sha256-YhPpUHLZUnYwOuc8RhegC2QeTfZNllKqKREMuMAmBa4=";
  };
  "src/third_party/dart/third_party/pkg/source_span" = fetchFromGoogle {
    owner = "dart";
    repo = "source_span";
    rev = "24151fd80e4557a626f81f2bc0d6a2ebde172cae";
    sha256 = "sha256-y6odFc/XTRL32KKPllgBSo3AnbVeqnmqRVnHTu1U75c=";
  };
  "src/third_party/dart/third_party/pkg/sse" = fetchFromGoogle {
    owner = "dart";
    repo = "sse";
    rev = "2df072848a6090d3ed67f30c69e86ec4d6b96cd6";
    sha256 = "sha256-/4lxFoxDrG2oQ4iBq7gz1FPvwwrQkr+7iNVb9ohptQs=";
  };
  "src/third_party/dart/third_party/pkg/stack_trace" = fetchFromGoogle {
    owner = "dart";
    repo = "stack_trace";
    rev = "17f09c2c6845bb31c7c385acecce5befb8527a13";
    sha256 = "sha256-9+kbfJehKIMfx9Dswy0n3M8eGJ9Xys8En1yArzq+tMw=";
  };
  "src/third_party/dart/third_party/pkg/stream_channel" = fetchFromGoogle {
    owner = "dart";
    repo = "stream_channel";
    rev = "8e0d7ef1f4a3fb97fbd82e11cd539093f58511f3";
    sha256 = "sha256-voQSBSU+lO5eaWUZFJV1fdlpER3mJgHrquX+odu6WEg=";
  };
  "src/third_party/dart/third_party/pkg/string_scanner" = fetchFromGoogle {
    owner = "dart";
    repo = "string_scanner";
    rev = "c637deb8d998b72a5807afbd06aba8370db725c0";
    sha256 = "sha256-BdXE25SnlF7oHfrF5jvkN/Cc5E/iKLZTASRaWy2nC1E=";
  };
  "src/third_party/dart/third_party/pkg/term_glyph" = fetchFromGoogle {
    owner = "dart";
    repo = "term_glyph";
    rev = "741efdedf9da62ee66a06c295d36fa28f8780e24";
    sha256 = "sha256-kOJyqCBt+6DUyt5je/MarwXy416kC72GQxlW1LPQNfw=";
  };
  "src/third_party/dart/third_party/pkg/test" = fetchFromGoogle {
    owner = "dart";
    repo = "test";
    rev = "fb4ccaf6c68fcc1d208c5c53a52d8e0e718bdffe";
    sha256 = "sha256-RUpkEz2+7Of5T+2rTOdQjtOxZ7YqwtFwJoP+b0YprL4=";
  };
  "src/third_party/dart/third_party/pkg/test_reflective_loader" = fetchFromGoogle {
    owner = "dart";
    repo = "test_reflective_loader";
    rev = "8d0de01bbe852fea1f8e33aba907abcba50a8a1e";
    sha256 = "sha256-dwHHvGxnm3hhx4k7uk1baZkGI/PHZnkxsXZl34mCtDk=";
  };
  "src/third_party/dart/third_party/pkg/typed_data" = fetchFromGoogle {
    owner = "dart";
    repo = "typed_data";
    rev = "bb10b64f9a56b8fb49307d4465474bf1c1309f6d";
    sha256 = "sha256-HgJTeslbdb2FqHtow8QFR1ks73fZT1uGhsWq3hwm5VM=";
  };
  "src/third_party/dart/third_party/pkg/usage" = fetchFromGoogle {
    owner = "dart";
    repo = "usage";
    rev = "1d3c31e780af665fb796a27898a441fcb7d263db";
    sha256 = "sha256-y4Y1d2e6F99pyNaWb/hWqwwpXvE5I6mHtTn4dfw+UDo=";
  };
  "src/third_party/dart/third_party/pkg/watcher" = fetchFromGoogle {
    owner = "dart";
    repo = "watcher";
    rev = "e00c0ea769e32821d91c0880da8eb736839a6e6d";
    sha256 = "sha256-qipUunpdlMpTqu5KxGiCbAoqoGZmbohaqO6Mg83xeXM=";
  };
  "src/third_party/dart/third_party/pkg/web_socket_channel" = fetchFromGoogle {
    owner = "dart";
    repo = "web_socket_channel";
    rev = "99dbdc5769e19b9eeaf69449a59079153c6a8b1f";
    sha256 = "sha256-NgSMQavssvef1opWxrBwE8BoZbIDAPftYmuSO+MU+k8=";
  };
  "src/third_party/dart/third_party/pkg/webdev" = fetchFromGoogle {
    owner = "dart";
    repo = "webdev";
    rev = "9c4428472b04f50748ea4871829897cff43455a3";
    sha256 = "sha256-bE1zFH0If15FJ3AlgCiksoyUJm9JfVhmhQgwkq+Oat0=";
  };
  "src/third_party/dart/third_party/pkg/webkit_inspection_protocol" = fetchFromGoogle {
    owner = "dart";
    repo = "external/github.com/google/webkit_inspection_protocol.dart";
    rev = "57522d6b29d94903b765c757079d906555d5a171";
    sha256 = "sha256-reLU4K2i83LQpUx940qt1YnsaTlPlVwF2LOdL26egxY=";
  };
  "src/third_party/dart/third_party/pkg/yaml" = fetchFromGoogle {
    owner = "dart";
    repo = "yaml";
    rev = "fda5b15692ccfa0feb7793a27fe3829b3d0f77fa";
    sha256 = "sha256-dtRSCQNqHJyaT+fgfxjxHTdhBUZIvsXpXKmu2MP6fDs=";
  };
  "src/third_party/dart/third_party/pkg/yaml_edit" = fetchFromGoogle {
    owner = "dart";
    repo = "yaml_edit";
    rev = "01589b3ce447b03aed991db49f1ec6445ad5476d";
    sha256 = "sha256-3DFvwcZyENzLFM0ilMACuDEBeJt7xB1GZGAY2c0tFcU=";
  };
  "src/third_party/dart/tools/sdks" = fetchcipd {
    name = "dart-sdk";
    package = "dart/dart-sdk/\${platform}";
    version = "version:2.17.0";
    sha256 = "sha256-5kzEm04Zikgw0LMkQMbKdkaBB8R03pwG0O1OoTD6BTg=";
  };
  "src/third_party/expat" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/libexpat/libexpat";
    rev = "a28238bdeebc087071777001245df1876a11f5ee";
    sha256 = "sha256-DbQCT0tsDKyGUwoKL5JxvW9Wjo2Rsu4kjNmSLgD708M=";
  };
  "src/third_party/fontconfig" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/fontconfig";
    rev = "81c83d510ae3aa75589435ce32a5de05139aacb0";
    sha256 = "sha256-5NMOtJ/QksN4Qb4HRoLdV53WkZrk6XOwveXxbd5WGds=";
  };
  "src/third_party/fontconfig/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/fontconfig";
    rev = "c336b8471877371f0190ba06f7547c54e2b890ba";
    sha256 = "sha256-48tHHCEogECtWZdt0iAm7fMQ1Wg+CPc0tDSuiPLUJZ0=";
  };
  "src/third_party/flatbuffers" = fetchFromGitHub {
    owner = "google";
    repo = "flatbuffers";
    rev = "0a80646371179f8a7a5c1f42c31ee1d44dcf6709";
    sha256 = "sha256-qIpY14ASn1IxvUpHR3cWvczas2REVDBSO5i2YdwOr8U=";
  };
  "src/third_party/freetype2" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/freetype2";
    rev = "3bea2761290a1cbe7d8f75c1c5a7ad727f826a66";
    sha256 = "sha256-MownlUy0MMEHQoO5zxi2adgzeZYySvqUc2wk7Ucljts=";
  };
  "src/third_party/fuchsia-vulkan" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/Vulkan-Headers";
    rev = "32640ad82ef648768c706c9bf828b77123a09bc2";
    sha256 = "sha256-O1mkYePuSXCT8X5xNMqOk1Y4VOgSw9hGAo3KHIijHvQ=";
  };
  "src/third_party/glfw" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/glfw";
    rev = "78e6a0063d27ed44c2c4805606309744f6fb29fc";
    sha256 = "sha256-RaVa4zg9Phcy4nhltITaGEOK34soLb6nNatV8yRoDnI=";
  };
  "src/third_party/googletest" = fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    rev = "054a986a8513149e8374fc669a5fe40117ca6b41";
    sha256 = "sha256-0fHPvyRv3dm794usuCoRSXHqVZKCS6qtEz41PfBNP/s=";
  };
  "src/third_party/gtest-parallel" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/google/gtest-parallel";
    rev = "38191e2733d7cbaeaef6a3f1a942ddeb38a2ad14";
    sha256 = "sha256-Q+hcFcBkKoV2nOJ9LPrP9tliUK02DEN2Zc4l2w1QodQ=";
  };
  "src/third_party/harfbuzz" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/harfbuzz";
    rev = "d40d15e994ed60d32bcfc9ab87004dfb028dfbd6";
    sha256 = "sha256-l7HsqDmEHFFWckV816ZlwK8Z1Y2ObB4wtMXzHtKoV5A=";
  };
  "src/third_party/icu" = fetchFromGoogle {
    owner = "chromium";
    repo = "chromium/deps/icu";
    rev = "12de966fcbe1d1a48dba310aee63807856ffeee8";
    sha256 = "sha256-VMXXVc5h6ty0LFeKa6sZEpnHyOshfHGNx6QL2NFmOhI=";
  };
  "src/third_party/imgui" = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    rev = "29d462ebce0275345a6ce4621d8fff0ded57c9e5";
    sha256 = "sha256-We72wUPsUrg3NxXtbFB96TwtSB98k07EByYCweR+IzE=";
  };
  "src/third_party/inja" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/inja";
    rev = "88bd6112575a80d004e551c98cf956f88ff4d445";
    sha256 = "sha256-JB/kM5N2jiF1pwvBKo/QkLBIUML74eZ3ifcJA330Ejk=";
  };
  "src/third_party/khronos" = fetchFromGoogle {
    owner = "chromium";
    repo = "chromium/src/third_party/khronos";
    rev = "676d544d2b8f48903b7da9fceffaa534a5613978";
    sha256 = "sha256-Gn4TnNbcxNAnefn1dP8EXG+SESpZluFwwQ+HnPrGqLI=";
  };
  "src/third_party/libcxx" = fetchFromGoogle {
    owner = "llvm";
    repo = "libcxx";
    rev = "7524ef50093a376f334a62a7e5cebf5d238d4c99";
    sha256 = "sha256-K1hgjOLp02rPXG313vkso07wXYa8ZO/qMTZCCbE8Fxs=";
  };
  "src/third_party/libcxxabi" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/libcxxabi";
    rev = "74d1e602c76350f0760bf6907910e4f3a4fccffe";
    sha256 = "sha256-C7n8LfotrG+Dxtj0yVOHlFM10Ugb2CM16HgLaiZJSFE=";
  };
  "src/third_party/libjpeg-turbo" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/libjpeg-turbo";
    rev = "0fb821f3b2e570b2783a94ccd9a2fb1f4916ae9f";
    sha256 = "sha256-rDyTBe/RTJ74Xv8BlI0j0wxtQGq4LufhVegXJRp9ak8=";
  };
  "src/third_party/libpng" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/libpng";
    rev = "134cf139cb24d802ee6ad5fc51bccff3221c2b49";
    sha256 = "sha256-b5/VNriaV59GtI45Fng09NEfqFAIdHxoq7S4Vcea2tI=";
  };
  "src/third_party/libtess2" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/libtess2";
    rev = "fc52516467dfa124bdd967c15c7cf9faf02a34ca";
    sha256 = "sha256-C6L6PviVFauMrBGWV78y+M9Z6YGTRXr1Y8jmu99bEpk=";
  };
  "src/third_party/libwebp" = fetchFromGoogle {
    owner = "chromium";
    repo = "webm/libwebp";
    rev = "7dfde712a477e420968732161539011e0fd446cf";
    sha256 = "sha256-6EKh6QIO0MKnaHf0H/cXhDvhv8+ySAH5aevPp/LuYsY=";
  };
  "src/third_party/libxml" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/libxml";
    rev = "a143e452b5fc7d872813eeadc8db421694058098";
    sha256 = "sha256-ZE0CVI21vlbXh8EJNgd58VELAjH3AIUMjittt0i+/m8=";
  };
  "src/third_party/ocmock" = fetchFromGitHub {
    owner = "erikdoe";
    repo = "ocmock";
    rev = "c4ec0e3a7a9f56cfdbd0aa01f4f97bb4b75c5ef8";
    sha256 = "sha256-uoU1Ko2k2Vf2cY8cZcl/MNIZgbE/96IM1TJet0ep6tk=";
  };
  "src/third_party/pyyaml" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/pyyaml";
    rev = "25e97546488eee166b1abb229a27856cecd8b7ac";
    sha256 = "sha256-V0a7Pp7PZLHD/XFWs8Rr2qRYLi3R8D5YPGcIRW/T2K0=";
  };
  "src/third_party/pkg/archive" = fetchFromGitHub {
    owner = "brendan-duncan";
    repo = "archive";
    rev = "9de7a0544457c6aba755ccb65abb41b0dc1db70d";
    sha256 = "sha256-J8c92JSdfOPwzgmwefFr5t7EofIUUYmm1529oVSwuJw=";
  };
  "src/third_party/pkg/equatable" = fetchFromGitHub {
    owner = "felangel";
    repo = "equatable";
    rev = "0ba67c72db8bed75877fc1caafa74112ee0bd921";
    sha256 = "sha256-r/IbXdLyN+hp3d+7gAc+sTV+wc1NrHS+tp+wwSWvjW0=";
  };
  "src/third_party/pkg/file" = fetchFromGitHub {
    owner = "google";
    repo = "file.dart";
    rev = "427bb20ccc852425d67f2880da2a9b4707c266b4";
    sha256 = "sha256-yP/WPL7gQJOrGrZtzXt8sJmVEbdz6lR7J1t8Kar5yRY=";
  };
  "src/third_party/pkg/flutter_packages" = fetchFromGitHub {
    owner = "flutter";
    repo = "packages";
    rev = "a19eca7fe2660c71acf5928a275deda1da318c50";
    sha256 = "sha256-vzR8TcJIRvFbKo22ZvO+gJmOTOmASNAfqthddcM8tac=";
  };
  "src/third_party/pkg/gcloud" = fetchFromGitHub {
    owner = "dart-lang";
    repo = "gcloud";
    rev = "92a33a9d95ea94a4354b052a28b98088d660e0e7";
    sha256 = "sha256-cqnVg8YhzDZuq5p+CTR6kvZlwRTReE+JhRnx004A5Uo=";
  };
  "src/third_party/pkg/googleapis" = fetchFromGitHub {
    owner = "google";
    repo = "googleapis.dart";
    rev = "07f01b7aa6985e4cafd0fd4b98724841bc9e85a1";
    sha256 = "sha256-U7vM+dUtGofG/qqYF/SYCJ//tm5qNdUYvnCECuVSOxI=";
  };
  "src/third_party/pkg/platform" = fetchFromGitHub {
    owner = "google";
    repo = "platform.dart";
    rev = "1ffad63428bbd1b3ecaa15926bacfb724023648c";
    sha256 = "sha256-knW3H0vRUzGsOA07JxPjNcJ60ejde3wZMsFoVOyBkG8=";
  };
  "src/third_party/pkg/process" = fetchFromGitHub {
    owner = "google";
    repo = "process.dart";
    rev = "0c9aeac86dcc4e3a6cf760b76fed507107e244d5";
    sha256 = "sha256-uTv5ClXb2IzQ3Uwov/cTe5Nk2FsWHrmAm9FhLf+hYwM=";
  };
  "src/third_party/pkg/process_runner" = fetchFromGitHub {
    owner = "google";
    repo = "process_runner";
    rev = "d632ea0bfd814d779fcc53a361ed33eaf3620a0b";
    sha256 = "sha256-AjmOhBTMWHpdoQdoyMjBFAwu92oGIgS6ST4rCW+cUEE=";
  };
  "src/third_party/pkg/quiver" = fetchFromGitHub {
    owner = "google";
    repo = "quiver-dart";
    rev = "66f473cca1332496e34a783ba4527b04388fd561";
    sha256 = "sha256-R6bAIBme36OtX67Vuf6gSjdMUbni2hhsoMHrlCmoAy0=";
  };
  "src/third_party/pkg/vector_math" = fetchFromGitHub {
    owner = "google";
    repo = "vector_math.dart";
    rev = "0a5fd95449083d404df9768bc1b321b88a7d2eef";
    sha256 = "sha256-nRd/PEB851Gw228Gkjecrw2T8REE4vPolgsrasnlkEY=";
  };
  "src/third_party/rapidjson" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/rapidjson";
    rev = "ef3564c5c8824989393b87df25355baf35ff544b";
    sha256 = "sha256-Vs34muNHWJ6F2yUXyKDsoWfSEBJ7g/0vwyfNj3ifIr4=";
  };
  "src/third_party/root_certificates" = fetchFromGoogle {
    owner = "dart";
    repo = "root_certificates";
    rev = "692f6d6488af68e0121317a9c2c9eb393eb0ee50";
    sha256 = "sha256-VTc/1YND17YyRndCNcDtgP8ZROf16dk7GcQv9SF+ybQ=";
  };
  "src/third_party/shaderc" = fetchFromGitHub {
    owner = "google";
    repo = "shaderc";
    rev = "948660cccfbbc303d2590c7f44a4cee40b66fdd6";
    sha256 = "sha256-NemeG33MamqF/PorhhtL04ysxIFbije5yETsCEDE3kE=";
  };
  "src/third_party/skia" = fetchFromGoogle {
    owner = "skia";
    repo = "skia";
    rev = "936433124f938c06d5b1609d534cd9b693edd71c";
    sha256 = "sha256-uXlCWSOI+ROwKyyndCw702Rw72Yurp2+5yGMblwK3tw=";
  };
  "src/third_party/sqlite" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/sqlite";
    rev = "0f61bd2023ba94423b4e4c8cfb1a23de1fe6a21c";
    sha256 = "sha256-PY1PaV7C3cVDCRyePVkR20/9rY0A3yJHqobCFY9Gisc=";
  };
  "src/third_party/swiftshader" = fetchFromGoogle {
    owner = "swiftshader";
    repo = "SwiftShader";
    rev = "bea8d2471bd912220ba59032e0738f3364632657";
    sha256 = "sha256-v0EXk5zS2QZcwslyd81/hnEdPc55v859c80220QpxeA=";
  };
  "src/third_party/vulkan-deps" = fetchFromGoogle {
    owner = "chromium";
    repo = "vulkan-deps";
    rev = "23b710f1a0b3c44d51035c6400a554415f95d9c6";
    sha256 = "sha256-O9bLm8eFY5+dcTmNZRZiIezGqpU2exQy6bSQ7Z1lOZ4=";
  };
  "src/third_party/vulkan-deps/glslang/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/glslang";
    rev = "316f12ac1d4f2fc9517ee1a18b2d710561df228c";
    sha256 = "sha256-yc8qdKBT4dSHCE9p+XFy9hQrBQIqI7/WJyr5CAX9Frg=";
  };
  "src/third_party/vulkan-deps/spirv-cross/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/SPIRV-Cross";
    rev = "50b4d5389b6a06f86fb63a2848e1a7da6d9755ca";
    sha256 = "sha256-N3/9BB3fXCzWBJvxZNl1fnz4HGYdwNaeHjhvxxfZ+Kk=";
  };
  "src/third_party/vulkan-deps/spirv-headers/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/SPIRV-Headers";
    rev = "b2a156e1c0434bc8c99aaebba1c7be98be7ac580";
    sha256 = "sha256-dvWYHEnzjDbj9B0dkEL8IL1OfVKrwRUb2x/XQKLusms=";
  };
  "src/third_party/vulkan-deps/spirv-tools/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/SPIRV-Tools";
    rev = "b930e734ea198b7aabbbf04ee1562cf6f57962f0";
    sha256 = "sha256-siqV6Cqd7bLHK4Z9nZ/qFzXfbK3sXBc1nHJTqqM/kN4=";
  };
  "src/third_party/vulkan-deps/vulkan-headers/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/Vulkan-Headers";
    rev = "245d25ce8c3337919dc7916d0e62e31a0d8748ab";
    sha256 = "sha256-Qlf0Bu/LgdfszpViv6926JiT8I8s1AVNIhHeKuM/dgU=";
  };
  "src/third_party/vulkan-deps/vulkan-loader/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/Vulkan-Loader";
    rev = "5437a0854fb6b664e2c48c0b8e7b157ac23fe741";
    sha256 = "sha256-01vFu17pOOyIdz0u9BLjK6symJQ4zWr9f8B3KdbAV4g=";
  };
  "src/third_party/vulkan-deps/vulkan-tools/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/Vulkan-Tools";
    rev = "dd7e8d2fbbdaca099e9ada77fec178e12a6b37d5";
    sha256 = "sha256-wHpgl6Xx3cuwmmZ+kkxHHV2jdu2ia9upw9iiBCBb18M=";
  };
  "src/third_party/vulkan-deps/vulkan-validation-layers/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/Vulkan-ValidationLayers";
    rev = "c97b4d72932091591713277f4b3e5b70f89736a2";
    sha256 = "sha256-aMWNBOB0Udua2rdIJJpxVcN3BGMpxz65+ucfokRICXk=";
  };
  "src/third_party/vulkan_memory_allocator" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator";
    rev = "7de5cc00de50e71a3aab22dea52fbb7ff4efceb6";
    sha256 = "sha256-TLDwWrqvRRYx6cNlIwuIW/AwbCkgJwWGFMGPtjBziTU=";
  };
  "src/third_party/wuffs" = fetchFromGoogle {
    owner = "skia";
    repo = "external/github.com/google/wuffs-mirror-release-c";
    rev = "600cd96cf47788ee3a74b40a6028b035c9fd6a61";
    sha256 = "sha256-GQr1MBNDflvMO3CfZtJEK8Eyl5hUndE6AVAvZcSX4nw=";
  };
  "src/third_party/yapf" = fetchFromGitHub {
    owner = "google";
    repo = "yapf";
    rev = "212c5b5ad8e172d2d914ae454c121c89cccbcb35";
    sha256 = "sha256-AHpwAEm293r0FdtwOB2G+8eMHPqUQwEFgL29GDrWvWM=";
  };
  "src/third_party/zlib" = fetchFromGoogle {
    owner = "chromium";
    repo = "chromium/src/third_party/zlib";
    rev = "27c2f474b71d0d20764f86f60ef8b00da1a16cda";
    sha256 = "sha256-xqgz9X7/U42BRveZCokRJ/1q8xQ5hNjyps0+Bx7K2WE=";
  };
}
