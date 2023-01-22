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
    sha256 = "sha256-03jr3H1RvzGfa0rBPZ1rtNpmieKzDjDgBsrZGaj7vuI=";
  };
  "src/third_party/abseil-cpp" = fetchFromGoogle {
    owner = "chromium";
    repo = "chromium/src/third_party/abseil-cpp";
    rev = "2d8c1340f0350828f1287c4eaeebefcf317bcfc9";
    sha256 = "sha256-L8LMn5uH9fesuKV8OQzWHjdhRQskZYh78nLnP7Tyj3M=";
  };
  "src/third_party/angle" = fetchFromGoogle {
    owner = "chromium";
    repo = "angle/angle";
    rev = "3faaded8234b31dea24c929e40e33089a34a9aa5";
    sha256 = "sha256-bdqC57q9BkhExDsbdCpFhAOwg9o+Gy49qQMez45DXFY=";
  };
  "src/third_party/benchmark" = fetchFromGitHub {
    owner = "google";
    repo = "benchmark";
    rev = "431abd149fd76a072f821913c0340137cc755f36";
    sha256 = "sha256-5Qjqfu8HTB0TPlMIFtjNrFIZ8sA9eUYV6u7P43QD5UI=";
  };
  "src/third_party/boringssl" = fetchFromGitHub {
    owner = "dart-lang";
    repo = "boringssl_gen";
    rev = "ced85ef0a00bbca77ce5a91261a5f2ae61b1e62f";
    sha256 = "sha256-7MAIkBb8nYdJIAggjV/WATHF03PEnWSdHNuhsZqTU5w=";
  };
  "src/third_party/boringssl/src" = fetchFromGoogle {
    owner = "boringssl";
    repo = "boringssl";
    rev = "87f316d7748268eb56f2dc147bd593254ae93198";
    sha256 = "sha256-KdU1PyUXet5H6xbBCb8xGMI6FBXziKIi2EzD15QpI5I=";
  };
  "src/third_party/colorama/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/colorama";
    rev = "799604a1041e9b3bc5d2789ecbd7e8db2e18e6b8";
    sha256 = "sha256-GB9EYyG7qYEF8YvXzpntvxBbnUPRIx0GAUfoLBjojlI=";
  };
  "src/third_party/dart" = fetchFromGoogle {
    owner = "dart";
    repo = "sdk";
    rev = "b6592742d9f1a82af319f46eda3d59a61e89b91b";
    sha256 = "sha256-kMpY7ZZYtbv5k0VUyjw7C7PGHH0W7g8JFYIbTdp/GNo=";
  };
  "src/third_party/dart/third_party/pkg/args" = fetchFromGoogle {
    owner = "dart";
    repo = "args";
    rev = "73e8d3b55cbedc9765f8e266f3422d8914f8e62a";
    sha256 = "sha256-3W9KlVn/p2Ttjl6koH9cSy3Q/WW6cdoGLVsXp7ZR3RU=";
  };
  "src/third_party/dart/third_party/pkg/async" = fetchFromGoogle {
    owner = "dart";
    repo = "async";
    rev = "f3ed5f690e2ec9dbe1bfc5184705575b4f6480e5";
    sha256 = "sha256-fJQqgzFWyFbQgVLMqxcozASWK/oqbMOw1Ov661IyWl8=";
  };
  "src/third_party/dart/third_party/pkg/bazel_worker" = fetchFromGoogle {
    owner = "dart";
    repo = "bazel_worker";
    rev = "9710de6c9c70b1b583183db9d9721ba64e5a16fe";
    sha256 = "sha256-1BdntRrDK2mbhQMfjLI/aGZcWUknx348+Aqs0+BzGvk=";
  };
  "src/third_party/dart/third_party/pkg/boolean_selector" = fetchFromGoogle {
    owner = "dart";
    repo = "boolean_selector";
    rev = "1d3565e2651d16566bb556955b96ea75018cbd0c";
    sha256 = "sha256-Vuo4zj/EN3rWhqD+bdIUe7mFT5NWzdli4M+7yNGeK6I=";
  };
  "src/third_party/dart/third_party/pkg/browser_launcher" = fetchFromGoogle {
    owner = "dart";
    repo = "browser_launcher";
    rev = "981ca8847dd2b0fe022f9e742045cfb8f214d35f";
    sha256 = "sha256-hSNBPXvmKrGVxQzmTrXGGnfHtor1+Q1lFxYL+Em1SyU=";
  };
  "src/third_party/dart/third_party/pkg/cli_util" = fetchFromGoogle {
    owner = "dart";
    repo = "cli_util";
    rev = "b0adbba89442b2ea6fef39c7a82fe79cb31e1168";
    sha256 = "sha256-j1cBFJyqMV4a2RSwJBBnsCrEuLdNDcQOsdfplChXQa4=";
  };
  "src/third_party/dart/third_party/pkg/clock" = fetchFromGoogle {
    owner = "dart";
    repo = "clock";
    rev = "2507a228773c5e877fc9e3330080b234aad965c0";
    sha256 = "sha256-CXJnQ/uJFAmuWxF3XaAp4F7wF978bG7e0Me/AkGfaTs=";
  };
  "src/third_party/dart/third_party/pkg/collection" = fetchFromGoogle {
    owner = "dart";
    repo = "collection";
    rev = "414ffa1bc8ba18bd608bbf916d95715311d89ac1";
    sha256 = "sha256-3HjoETJI6rOyChpUN+OHXrQBXlsm8uD4wjSu85Rng60=";
  };
  "src/third_party/dart/third_party/pkg/convert" = fetchFromGoogle {
    owner = "dart";
    repo = "convert";
    rev = "7145da14f9cd730e80fb4c6a10108fcfd205e8e7";
    sha256 = "sha256-FabAkPcFGeQ0j9rEe+TM10FPIUYps5GQmk6gUxix1CE=";
  };
  "src/third_party/dart/third_party/pkg/crypto" = fetchFromGoogle {
    owner = "dart";
    repo = "crypto";
    rev = "223e0a62c0f762fd2b510f753861445b52e14fc3";
    sha256 = "sha256-u0g06u41YrPZmyp9URJfO4GWIOoLjsrpZe77bCxuMRY=";
  };
  "src/third_party/dart/third_party/pkg/csslib" = fetchFromGoogle {
    owner = "dart";
    repo = "csslib";
    rev = "ba2eb2d80530eedefadaade338a09c2dd60410f3";
    sha256 = "sha256-d4/uDXcNIVk56A6fNQk5unZ8+AgdeIoyDoQS63RikQ0=";
  };
  "src/third_party/dart/third_party/pkg/dart_style" = fetchFromGoogle {
    owner = "dart";
    repo = "dart_style";
    rev = "d7b73536a8079331c888b7da539b80e6825270ea";
    sha256 = "sha256-N8TQt88hM25O1m0geLtW9QDvHE8d/xXqPoumgWCtI6Y=";
  };
  "src/third_party/dart/third_party/pkg/dartdoc" = fetchFromGoogle {
    owner = "dart";
    repo = "dartdoc";
    rev = "adc5a45ddafb57e3a600ee7d9e88dc81061d1410";
    sha256 = "sha256-QiVM6HsAt1QCfBTTBYsQibXzG2FxXq7My5oUBIlPKwY=";
  };
  "src/third_party/dart/third_party/pkg/ffi" = fetchFromGoogle {
    owner = "dart";
    repo = "ffi";
    rev = "18b2b549d55009ff594600b04705ff6161681e07";
    sha256 = "sha256-BiPw0boe1nwvdck2YZLQPQT6foM2u2n10eDFtPD8eZQ=";
  };
  "src/third_party/dart/third_party/pkg/file" = fetchFromGoogle {
    owner = "dart";
    repo = "external/github.com/google/file.dart";
    rev = "0132eeedea2933513bf230513a766a8baeab0c4f";
    sha256 = "sha256-IceTl2K66YaUy7oPyNJKu3FN8o14e9GfPjGVJWOzM00=";
  };
  "src/third_party/dart/third_party/pkg/fixnum" = fetchFromGoogle {
    owner = "dart";
    repo = "fixnum";
    rev = "164712f6547cdfb2709b752188186baf31fd1730";
    sha256 = "sha256-IH7skpBHfdx4hUOuqYgx17SbUPhJ90LMrxrkTovPoZs=";
  };
  "src/third_party/dart/third_party/pkg/glob" = fetchFromGoogle {
    owner = "dart";
    repo = "glob";
    rev = "1d51fcc172e5adfbae6e82c3f8f119774cb2fca2";
    sha256 = "sha256-YWPnFtNtK4gImncNkz50WrPxbbZKk0X1B8uSlGjjjCY=";
  };
  "src/third_party/dart/third_party/pkg/html" = fetchFromGoogle {
    owner = "dart";
    repo = "html";
    rev = "8243e967caad9932c13971af3b2a7c8f028383d5";
    sha256 = "sha256-bUsoYvEV8+WBDPyfTdl/1hZ6O1wVoGb/vm5b+/VccJ0=";
  };
  "src/third_party/dart/third_party/pkg/http" = fetchFromGoogle {
    owner = "dart";
    repo = "http";
    rev = "843c5ecb1ea2233ba7b7049833b5801b149fba86";
    sha256 = "sha256-YVKAh2tSoP0CeMIgjsTfKSbdLMHDQilLf/5yvub+uUs=";
  };
  "src/third_party/dart/third_party/pkg/http_multi_server" = fetchFromGoogle {
    owner = "dart";
    repo = "http_multi_server";
    rev = "20bf079c8955d1250a45afb9cb096472a724a551";
    sha256 = "sha256-6LtilQyiZ3ufhl2SrQJGRRUpC3SPC5kwHcz5bhsDIWo=";
  };
  "src/third_party/dart/third_party/pkg/http_parser" = fetchFromGoogle {
    owner = "dart";
    repo = "http_parser";
    rev = "eaa63304c333316acd114e3be7ed701d7d7ba32c";
    sha256 = "sha256-cTU6kCC7wcNyxjnWd432iq2BaahZtuJ07QJSw6gWM2M=";
  };
  "src/third_party/dart/third_party/pkg/json_rpc_2" = fetchFromGoogle {
    owner = "dart";
    repo = "json_rpc_2";
    rev = "805e6536dd961d66f6b8cd46d8f3e61774f957c9";
    sha256 = "sha256-cZYXqBih4OEf6QLfkHhZHQQzPz5tcDdICqC7gkrcLnw=";
  };
  "src/third_party/dart/third_party/pkg/linter" = fetchFromGoogle {
    owner = "dart";
    repo = "linter";
    rev = "1ddc70948d94f2449fec69a95e3ceb7b6b6c8348";
    sha256 = "sha256-uZKwcOZujcbMtbhJfrJ6Zu8IeE0+3Eh6AiZpS+fKpIg=";
  };
  "src/third_party/dart/third_party/pkg/logging" = fetchFromGoogle {
    owner = "dart";
    repo = "logging";
    rev = "f6979e3bc3b6e1847a08335b7eb6304e18986195";
    sha256 = "sha256-gh9cKfH5l/jAfgbbtL2jQuThSOe6AqroLTHIh8pyQog=";
  };
  "src/third_party/dart/third_party/pkg/markdown" = fetchFromGoogle {
    owner = "dart";
    repo = "markdown";
    rev = "e3f4bd28c9e61b522f75f291d4d6cfcfeccd83ee";
    sha256 = "sha256-zmY9LaAI6HRV4BIYFqpB2eZBH9WzIXRBtqxt+oVZ3JY=";
  };
  "src/third_party/dart/third_party/pkg/matcher" = fetchFromGoogle {
    owner = "dart";
    repo = "matcher";
    rev = "1a7fcae0d7af1604781afabe61fd35d9b404d8ed";
    sha256 = "sha256-9eLY3lFbyw42hQYztU2ennBWdgESVIbTuRSaHVZfvjs=";
  };
  "src/third_party/dart/third_party/pkg/mime" = fetchFromGoogle {
    owner = "dart";
    repo = "mime";
    rev = "0a75a41445eb642674a0a271eecde78cb025ee60";
    sha256 = "sha256-Of667MOH1+DNY9T7y1G9RxsgJSlVC9jd65vyl03oaH0=";
  };
  "src/third_party/dart/third_party/pkg/mockito" = fetchFromGoogle {
    owner = "dart";
    repo = "mockito";
    rev = "25d25dab6b57ac710c0be0e759def7505b352ea7";
    sha256 = "sha256-ke56bJRnQ3hUeZnHxry7eXPsRD7i5vgq0bvOK9mGVjU=";
  };
  "src/third_party/dart/third_party/pkg/oauth2" = fetchFromGoogle {
    owner = "dart";
    repo = "oauth2";
    rev = "199ebf15cbd5b07958438184f32e41c4447a57bf";
    sha256 = "sha256-3wK3p7lSjt0d42palj6POR2I/cGnGg2wnTWAUO09fso=";
  };
  "src/third_party/dart/third_party/pkg/package_config" = fetchFromGoogle {
    owner = "dart";
    repo = "package_config";
    rev = "cff98c90acc457a3b0750f0a7da0e351a35e5d0c";
    sha256 = "sha256-SyBRHDgbxmElOMYuE/eeIWe1bgGRb/Eee8MJxvmZP6M=";
  };
  "src/third_party/dart/third_party/pkg/path" = fetchFromGoogle {
    owner = "dart";
    repo = "path";
    rev = "7a0ed40280345b1c11df4c700c71e590738f4257";
    sha256 = "sha256-v5GK8xY3IWc9Hlvs1/UZiRYfn9Q1E3m7eaBl6pqvgGQ=";
  };
  "src/third_party/dart/third_party/pkg/pool" = fetchFromGoogle {
    owner = "dart";
    repo = "pool";
    rev = "fa84ddd0e39f45bf3f09dcc5d6b9fbdda7820fef";
    sha256 = "sha256-VWgmLHgiwPPBTtm12qIUrDBrgxqGUuDoHK9jtqscfbY=";
  };
  "src/third_party/dart/third_party/pkg/protobuf" = fetchFromGoogle {
    owner = "dart";
    repo = "protobuf";
    rev = "2d6c6037cee6c5f683e8f38e598443f9bec74b94";
    sha256 = "sha256-g00NCh+VWNPmH1WWu3BRljc4pYB3HpqHdLOhCG1Vu8Y=";
  };
  "src/third_party/dart/third_party/pkg/pub" = fetchFromGoogle {
    owner = "dart";
    repo = "pub";
    rev = "9bf4289d6fd5d6872a8929d6312bbd7098f3ea9c";
    sha256 = "sha256-7CLGg/ZkmNZG2x9JX3FcytcQF6mco5D0UXqEXoe314Q=";
  };
  "src/third_party/dart/third_party/pkg/pub_semver" = fetchFromGoogle {
    owner = "dart";
    repo = "pub_semver";
    rev = "5c0b4bfd5ca57fe16f1319c581dc8c882e9b8cb2";
    sha256 = "sha256-6rD1vpJS883eeMZr9rC2uDK3hmiTabOf327v+EUxjRk=";
  };
  "src/third_party/dart/third_party/pkg/shelf" = fetchFromGoogle {
    owner = "dart";
    repo = "shelf";
    rev = "8f8f3703efd241f9cf6b18e36e0067ca74c47fd8";
    sha256 = "sha256-SlEXF7hW219+TFQwX2xsNHsSmVYJErOjn3jT1vBSHcg=";
  };
  "src/third_party/dart/third_party/pkg/source_map_stack_trace" = fetchFromGoogle {
    owner = "dart";
    repo = "source_map_stack_trace";
    rev = "72dbf21a33293b2b8434d0a9751e36f9463981ac";
    sha256 = "sha256-ZdbrKLIXBm/EnPORdmGE71JQHm22k4GA6lapK9AkMn4=";
  };
  "src/third_party/dart/third_party/pkg/source_maps" = fetchFromGoogle {
    owner = "dart";
    repo = "source_maps";
    rev = "e93565b43a7b6b367789de8ffba969c4ebeeb317";
    sha256 = "sha256-SlpTO8sHeuCZF4N8i9hdyW8k36liXzJGOuFK7kojuKs=";
  };
  "src/third_party/dart/third_party/pkg/source_span" = fetchFromGoogle {
    owner = "dart";
    repo = "source_span";
    rev = "24151fd80e4557a626f81f2bc0d6a2ebde172cae";
    sha256 = "sha256-asuq/ASOTOxoxZ6RHQhia+2ibp9Hnt3KLs3D8nMq/6Q=";
  };
  "src/third_party/dart/third_party/pkg/sse" = fetchFromGoogle {
    owner = "dart";
    repo = "sse";
    rev = "2df072848a6090d3ed67f30c69e86ec4d6b96cd6";
    sha256 = "sha256-5RQMJHXLsu7qYpmJu75ARL/T4xf9jiaVPBf5I9Vqeyo=";
  };
  "src/third_party/dart/third_party/pkg/stack_trace" = fetchFromGoogle {
    owner = "dart";
    repo = "stack_trace";
    rev = "17f09c2c6845bb31c7c385acecce5befb8527a13";
    sha256 = "sha256-G75ZiR6J9eQRI+SG4TYyJqWYvGHt4fdrKhy6Tqod2UM=";
  };
  "src/third_party/dart/third_party/pkg/stream_channel" = fetchFromGoogle {
    owner = "dart";
    repo = "stream_channel";
    rev = "8e0d7ef1f4a3fb97fbd82e11cd539093f58511f3";
    sha256 = "sha256-M0g/74wydyhJgeGzqaZBYYiMOODKFzFzBSEojCfPTmg=";
  };
  "src/third_party/dart/third_party/pkg/string_scanner" = fetchFromGoogle {
    owner = "dart";
    repo = "string_scanner";
    rev = "c637deb8d998b72a5807afbd06aba8370db725c0";
    sha256 = "sha256-oMc+W+23iHZBc68GX+jpWnKvWWThiJnH/JaLOB+xkuI=";
  };
  "src/third_party/dart/third_party/pkg/term_glyph" = fetchFromGoogle {
    owner = "dart";
    repo = "term_glyph";
    rev = "741efdedf9da62ee66a06c295d36fa28f8780e24";
    sha256 = "sha256-uWoUR6FsgB+3fNyjKHq/nE+2uFKgIR0P6+zJZhte8I0=";
  };
  "src/third_party/dart/third_party/pkg/test" = fetchFromGoogle {
    owner = "dart";
    repo = "test";
    rev = "fb4ccaf6c68fcc1d208c5c53a52d8e0e718bdffe";
    sha256 = "sha256-BQE2c2tpPAuj0D56seJafzFo0T5w+AheP6ZT4ukCJBc=";
  };
  "src/third_party/dart/third_party/pkg/test_reflective_loader" = fetchFromGoogle {
    owner = "dart";
    repo = "test_reflective_loader";
    rev = "8d0de01bbe852fea1f8e33aba907abcba50a8a1e";
    sha256 = "sha256-lU0zquIqUY2P0AQHTL/GUMhd4R304iHXa4E42HKTr0E=";
  };
  "src/third_party/dart/third_party/pkg/typed_data" = fetchFromGoogle {
    owner = "dart";
    repo = "typed_data";
    rev = "bb10b64f9a56b8fb49307d4465474bf1c1309f6d";
    sha256 = "sha256-aFmEOEjRSC8pYTUljqEiZ2pZjoSmXi1zbVmgiZFvHYY=";
  };
  "src/third_party/dart/third_party/pkg/usage" = fetchFromGoogle {
    owner = "dart";
    repo = "usage";
    rev = "1d3c31e780af665fb796a27898a441fcb7d263db";
    sha256 = "sha256-t8aPbYQBHolxMSqeK2BrXo778TzNspFy6PBJI/fS0ZY=";
  };
  "src/third_party/dart/third_party/pkg/watcher" = fetchFromGoogle {
    owner = "dart";
    repo = "watcher";
    rev = "e00c0ea769e32821d91c0880da8eb736839a6e6d";
    sha256 = "sha256-vbJTAGKbP21uQr+Pd5vsDG89oZBNIVXpf2e54PXk+X0=";
  };
  "src/third_party/dart/third_party/pkg/web_socket_channel" = fetchFromGoogle {
    owner = "dart";
    repo = "web_socket_channel";
    rev = "99dbdc5769e19b9eeaf69449a59079153c6a8b1f";
    sha256 = "sha256-p5McBKct7NxTA5r1m1gzHK8Xu6Bc/Ke0kvRHXSA+za0=";
  };
  "src/third_party/dart/third_party/pkg/webdev" = fetchFromGoogle {
    owner = "dart";
    repo = "webdev";
    rev = "9c4428472b04f50748ea4871829897cff43455a3";
    sha256 = "sha256-3Oqss40eh6Vg0Y+m9XMzcH4lLVDqTM8YYq36Vz1OOhY=";
  };
  "src/third_party/dart/third_party/pkg/webkit_inspection_protocol" = fetchFromGoogle {
    owner = "dart";
    repo = "external/github.com/google/webkit_inspection_protocol.dart";
    rev = "57522d6b29d94903b765c757079d906555d5a171";
    sha256 = "sha256-LcHlgIPcakfDQQScerJQTjpHR9wV3tYgiD/Pwpmrkmw=";
  };
  "src/third_party/dart/third_party/pkg/yaml" = fetchFromGoogle {
    owner = "dart";
    repo = "yaml";
    rev = "fda5b15692ccfa0feb7793a27fe3829b3d0f77fa";
    sha256 = "sha256-keSnPHCNmm601xk2WrUBlcrMYyIx0zRtG4RJluD2NJ8=";
  };
  "src/third_party/dart/third_party/pkg/yaml_edit" = fetchFromGoogle {
    owner = "dart";
    repo = "yaml_edit";
    rev = "01589b3ce447b03aed991db49f1ec6445ad5476d";
    sha256 = "sha256-wzlZhX7ZxL3jBfoBlUCjRM/awlyEZU1QO4rBEZmMr+8=";
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
    sha256 = "sha256-TSaVtKEk7J0fckDvpI6/U5Aq7d37nsixp0Ft7sMHi8w=";
  };
  "src/third_party/fontconfig" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/fontconfig";
    rev = "81c83d510ae3aa75589435ce32a5de05139aacb0";
    sha256 = "sha256-mXnbnMGpDAm4k7EnE3UB8QZNbMdKmU1PHWthfp9UaUY=";
  };
  "src/third_party/fontconfig/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/fontconfig";
    rev = "c336b8471877371f0190ba06f7547c54e2b890ba";
    sha256 = "sha256-wnDn8bek8RmL20381DJ1jUO4Rs0/49VY1GqCM8YojCM=";
  };
  "src/third_party/flatbuffers" = fetchFromGitHub {
    owner = "google";
    repo = "flatbuffers";
    rev = "0a80646371179f8a7a5c1f42c31ee1d44dcf6709";
    sha256 = "sha256-zV5DdaOVCs8GGqJ/5KY86yu4Udh9UDTkclYWSrPRJXQ=";
  };
  "src/third_party/freetype2" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/freetype2";
    rev = "3bea2761290a1cbe7d8f75c1c5a7ad727f826a66";
    sha256 = "sha256-qO7JtA+gdtdxbStbqJFDqVRmovEYwG0Ghk6XkyagisA=";
  };
  "src/third_party/fuchsia-vulkan" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/Vulkan-Headers";
    rev = "32640ad82ef648768c706c9bf828b77123a09bc2";
    sha256 = "sha256-zh1Obx3jqEeHAZ0qju2NQhz9Ns9CEMxVQU+E475X3N8=";
  };
  "src/third_party/glfw" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/glfw";
    rev = "78e6a0063d27ed44c2c4805606309744f6fb29fc";
    sha256 = "sha256-colkLmVkDHSTq+knUKDW/1HrLM0CTjjD8P1RbXgWijI=";
  };
  "src/third_party/googletest" = fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    rev = "054a986a8513149e8374fc669a5fe40117ca6b41";
    sha256 = "sha256-abvXbL7j3sM5WHqvFdjHSSF5Tcae54DkNyqgyBOUJi4=";
  };
  "src/third_party/gtest-parallel" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/google/gtest-parallel";
    rev = "38191e2733d7cbaeaef6a3f1a942ddeb38a2ad14";
    sha256 = "sha256-b5cUGeLwrznMX5Q1d9LR7bka+9A3bzp2O+ps3igj9Ro=";
  };
  "src/third_party/harfbuzz" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/harfbuzz";
    rev = "d40d15e994ed60d32bcfc9ab87004dfb028dfbd6";
    sha256 = "sha256-3Da6Cb+sgoRAl+k80VKmKGfGF65X5LlrKs/bU93cBn0=";
  };
  "src/third_party/icu" = fetchFromGoogle {
    owner = "chromium";
    repo = "chromium/deps/icu";
    rev = "12de966fcbe1d1a48dba310aee63807856ffeee8";
    sha256 = "sha256-b7i6VZZGUfE4VeXFK73QtrgpIP/bBfut7NebYCWWL9A=";
  };
  "src/third_party/imgui" = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    rev = "29d462ebce0275345a6ce4621d8fff0ded57c9e5";
    sha256 = "sha256-FIMEUvlwPsP7sgryMA+qflezKOS3SZl8Jy420KV3ZgE=";
  };
  "src/third_party/inja" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/inja";
    rev = "88bd6112575a80d004e551c98cf956f88ff4d445";
    sha256 = "sha256-lUSJ6nDyBxF1DcFyCwIG6Aajm7H8ZZrGc7Qj+cVzAlc=";
  };
  "src/third_party/khronos" = fetchFromGoogle {
    owner = "chromium";
    repo = "chromium/src/third_party/khronos";
    rev = "676d544d2b8f48903b7da9fceffaa534a5613978";
    sha256 = "sha256-zFU5U1hEvApvnUVNneN1QEa9yjEuXO6ccMrXdI5Wn+g=";
  };
  "src/third_party/libcxx" = fetchFromGoogle {
    owner = "llvm";
    repo = "libcxx";
    rev = "7524ef50093a376f334a62a7e5cebf5d238d4c99";
    sha256 = "sha256-CWajnpeH2auNTL2ha6HnCY1bUWeqStetBsI09peoK2U=";
  };
  "src/third_party/libcxxabi" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/libcxxabi";
    rev = "74d1e602c76350f0760bf6907910e4f3a4fccffe";
    sha256 = "sha256-3+NZ1xtlbT6AUHYoSwlo2iBkrP/Ar5vDgKHBk3tlSWI=";
  };
  "src/third_party/libjpeg-turbo" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/libjpeg-turbo";
    rev = "0fb821f3b2e570b2783a94ccd9a2fb1f4916ae9f";
    sha256 = "sha256-E0nhNQq09sgR31cHyddWbLBmuZM/8FJ5fzfpNkkYB80=";
  };
  "src/third_party/libpng" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/libpng";
    rev = "134cf139cb24d802ee6ad5fc51bccff3221c2b49";
    sha256 = "sha256-ruWqyOK1ZSeqghFO/USfuisDh6JGfFWYVQIKB88uLcU=";
  };
  "src/third_party/libtess2" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/libtess2";
    rev = "fc52516467dfa124bdd967c15c7cf9faf02a34ca";
    sha256 = "sha256-AvM7tave9LW3UrOuiUHsMF4Zeq2SQ+iJCITpnAJ7RhQ=";
  };
  "src/third_party/libwebp" = fetchFromGoogle {
    owner = "chromium";
    repo = "webm/libwebp";
    rev = "7dfde712a477e420968732161539011e0fd446cf";
    sha256 = "sha256-Lg+2fFJnAInkJD9fWcg8qa5e9L0De3bwbpA7++wQgiA=";
  };
  "src/third_party/libxml" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/libxml";
    rev = "a143e452b5fc7d872813eeadc8db421694058098";
    sha256 = "sha256-2HmdHdmcL93+p6eaZanqYwo0puN1rWfhOB2IGkymjBg=";
  };
  "src/third_party/ocmock" = fetchFromGitHub {
    owner = "erikdoe";
    repo = "ocmock";
    rev = "c4ec0e3a7a9f56cfdbd0aa01f4f97bb4b75c5ef8";
    sha256 = "sha256-5Io2ADZuBNizMroW9I/WGrN/BfpX7gsVp6b43DWAlq8=";
  };
  "src/third_party/pyyaml" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/pyyaml";
    rev = "25e97546488eee166b1abb229a27856cecd8b7ac";
    sha256 = "sha256-sOMywZPDzkFg4/jSjabaZlqYhgNbeKy0nCsr150Ozyw=";
  };
  "src/third_party/pkg/archive" = fetchFromGitHub {
    owner = "brendan-duncan";
    repo = "archive";
    rev = "9de7a0544457c6aba755ccb65abb41b0dc1db70d";
    sha256 = "sha256-oEarOhZwpPc67CfSTbLUrwnxlSlxerff80iVC8+H9+A=";
  };
  "src/third_party/pkg/equatable" = fetchFromGitHub {
    owner = "felangel";
    repo = "equatable";
    rev = "0ba67c72db8bed75877fc1caafa74112ee0bd921";
    sha256 = "sha256-81XamQA652vVWiNFR62H4nZLObECHexSCiY14bzO1Fo=";
  };
  "src/third_party/pkg/file" = fetchFromGitHub {
    owner = "google";
    repo = "file.dart";
    rev = "427bb20ccc852425d67f2880da2a9b4707c266b4";
    sha256 = "sha256-h9ITaTB0pzWrWE2X2pUCinRIL0/TCG9v/EPQprD8qWU=";
  };
  "src/third_party/pkg/flutter_packages" = fetchFromGitHub {
    owner = "flutter";
    repo = "packages";
    rev = "a19eca7fe2660c71acf5928a275deda1da318c50";
    sha256 = "sha256-GBxr0F1V4CG/VNeImK9fh0g/44xM0ZPnc2GjggMiZcs=";
  };
  "src/third_party/pkg/gcloud" = fetchFromGitHub {
    owner = "dart-lang";
    repo = "gcloud";
    rev = "92a33a9d95ea94a4354b052a28b98088d660e0e7";
    sha256 = "sha256-1d/U53R2iFJAg0lzFBTOSOAQ46u9rZHrFOBJkOQ128U=";
  };
  "src/third_party/pkg/googleapis" = fetchFromGitHub {
    owner = "google";
    repo = "googleapis.dart";
    rev = "07f01b7aa6985e4cafd0fd4b98724841bc9e85a1";
    sha256 = "sha256-IiiGjYrC8BfP5khSsiMrG/DU11sZaqDUC8/gq4ZkkSA=";
  };
  "src/third_party/pkg/platform" = fetchFromGitHub {
    owner = "google";
    repo = "platform.dart";
    rev = "1ffad63428bbd1b3ecaa15926bacfb724023648c";
    sha256 = "sha256-0ChNXyjZd8hyDoTdmOnrhLtKBiFKCKjGGX6Vr+OCyrY=";
  };
  "src/third_party/pkg/process" = fetchFromGitHub {
    owner = "google";
    repo = "process.dart";
    rev = "0c9aeac86dcc4e3a6cf760b76fed507107e244d5";
    sha256 = "sha256-a121J8Ha45AAKC0wftnVSThvPp0iXK7YxLfJokkHuq0=";
  };
  "src/third_party/pkg/process_runner" = fetchFromGitHub {
    owner = "google";
    repo = "process_runner";
    rev = "d632ea0bfd814d779fcc53a361ed33eaf3620a0b";
    sha256 = "sha256-4/9IbOu2dmgxy5d3mvb6IEbVfOtzJGu/2Iq/S7Fw4rs=";
  };
  "src/third_party/pkg/quiver" = fetchFromGitHub {
    owner = "google";
    repo = "quiver-dart";
    rev = "66f473cca1332496e34a783ba4527b04388fd561";
    sha256 = "sha256-0ubgn2cdi17sAeOcSiNblcIECiz2Zr6SPq/ZXwoI/i8=";
  };
  "src/third_party/pkg/vector_math" = fetchFromGitHub {
    owner = "google";
    repo = "vector_math.dart";
    rev = "0a5fd95449083d404df9768bc1b321b88a7d2eef";
    sha256 = "sha256-e9iVKJZ11h46taZ0Cl1/dm3YVfSYFFAlpNv4+CxM1cE=";
  };
  "src/third_party/rapidjson" = fetchFromGoogle {
    owner = "fuchsia";
    repo = "third_party/rapidjson";
    rev = "ef3564c5c8824989393b87df25355baf35ff544b";
    sha256 = "sha256-Z/XLVipfM7CrhYczVJo94J92CRAeTXi6BOaQTZusMFA=";
  };
  "src/third_party/root_certificates" = fetchFromGoogle {
    owner = "dart";
    repo = "root_certificates";
    rev = "692f6d6488af68e0121317a9c2c9eb393eb0ee50";
    sha256 = "sha256-dDIJScKg4PBCmyCipErHHkUHZQY7q8UvtBhtkljPkso=";
  };
  "src/third_party/shaderc" = fetchFromGitHub {
    owner = "google";
    repo = "shaderc";
    rev = "948660cccfbbc303d2590c7f44a4cee40b66fdd6";
    sha256 = "sha256-i2AerFcWeTM6a0EZE6/W5vElcVNUheukOJxcu1E0UD4=";
  };
  "src/third_party/skia" = fetchFromGoogle {
    owner = "skia";
    repo = "skia";
    rev = "936433124f938c06d5b1609d534cd9b693edd71c";
    sha256 = "sha256-/Ad63mcFPNeTpmC1XQ4g0iaCla0P6gpFk1agE7lHjKQ=";
  };
  "src/third_party/sqlite" = fetchFromGoogle {
    owner = "flutter";
    repo = "third_party/sqlite";
    rev = "0f61bd2023ba94423b4e4c8cfb1a23de1fe6a21c";
    sha256 = "sha256-EWnrl9yQrQCfivmvyBSM28eDto6u+jCPpV3fBq9Ryr8=";
  };
  "src/third_party/swiftshader" = fetchFromGoogle {
    owner = "swiftshader";
    repo = "SwiftShader";
    rev = "bea8d2471bd912220ba59032e0738f3364632657";
    sha256 = "sha256-h7Dl8WYBrlNhe6kHIEZzbG/zbkZQSWmapIXNFA6f4EE=";
  };
  "src/third_party/vulkan-deps" = fetchFromGoogle {
    owner = "chromium";
    repo = "vulkan-deps";
    rev = "23b710f1a0b3c44d51035c6400a554415f95d9c6";
    sha256 = "sha256-14tAv9nazYZemclD42rYDoGGFx5O44tvNB/16Zsm6kI=";
  };
  "src/third_party/vulkan-deps/glslang/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/glslang";
    rev = "316f12ac1d4f2fc9517ee1a18b2d710561df228c";
    sha256 = "sha256-ytxzR7LELYLPKEfGbxgcXkueLFu81u4c5YLg1qhxKxk=";
  };
  "src/third_party/vulkan-deps/spirv-cross/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/SPIRV-Cross";
    rev = "50b4d5389b6a06f86fb63a2848e1a7da6d9755ca";
    sha256 = "sha256-SsupPHJ3VHxJhEAUl3EeQwN4texYhdDjxTnGD+bkNAw=";
  };
  "src/third_party/vulkan-deps/spirv-headers/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/SPIRV-Headers";
    rev = "b2a156e1c0434bc8c99aaebba1c7be98be7ac580";
    sha256 = "sha256-qYhFoRrQOlvYvVXhIFsa3dZuORDpZyVC5peeYmGNimw=";
  };
  "src/third_party/vulkan-deps/spirv-tools/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/SPIRV-Tools";
    rev = "b930e734ea198b7aabbbf04ee1562cf6f57962f0";
    sha256 = "sha256-NWpFSRoxtYWi+hLUt9gpw0YScM3shcUwv9yUmbivRb0=";
  };
  "src/third_party/vulkan-deps/vulkan-headers/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/Vulkan-Headers";
    rev = "245d25ce8c3337919dc7916d0e62e31a0d8748ab";
    sha256 = "sha256-CzW3MiyArKaOiqvOhia5Ezdn1YStfsX3BaU4UatjQh8=";
  };
  "src/third_party/vulkan-deps/vulkan-loader/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/Vulkan-Loader";
    rev = "5437a0854fb6b664e2c48c0b8e7b157ac23fe741";
    sha256 = "sha256-dEcOLmngDwnqe90G/F+3aUEKqGSSBq0O+9tqwUmq28U=";
  };
  "src/third_party/vulkan-deps/vulkan-tools/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/Vulkan-Tools";
    rev = "dd7e8d2fbbdaca099e9ada77fec178e12a6b37d5";
    sha256 = "sha256-HSHhuKdFBCtM23kpe/CfTJ+fn3k2ykaX+ZnfJCEsJsc=";
  };
  "src/third_party/vulkan-deps/vulkan-validation-layers/src" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/KhronosGroup/Vulkan-ValidationLayers";
    rev = "c97b4d72932091591713277f4b3e5b70f89736a2";
    sha256 = "sha256-N8CcoFxas+sYM+wStDuMyZwpCFh0q+1ILyfi4368m70=";
  };
  "src/third_party/vulkan_memory_allocator" = fetchFromGoogle {
    owner = "chromium";
    repo = "external/github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator";
    rev = "7de5cc00de50e71a3aab22dea52fbb7ff4efceb6";
    sha256 = "sha256-rxr2RSZ7CrQwS/55HvKkw/LQXCO7R0oBR2lfD4olSpI=";
  };
  "src/third_party/wuffs" = fetchFromGoogle {
    owner = "skia";
    repo = "external/github.com/google/wuffs-mirror-release-c";
    rev = "600cd96cf47788ee3a74b40a6028b035c9fd6a61";
    sha256 = "sha256-/A772r/xkXBQRcCNIhdIlrlvxoAU3uQ25EolFagIVzo=";
  };
  "src/third_party/yapf" = fetchFromGitHub {
    owner = "google";
    repo = "yapf";
    rev = "212c5b5ad8e172d2d914ae454c121c89cccbcb35";
    sha256 = "sha256-u700Edu18ziS+Pf6nzOwTh9mJPIGiFW0+dFP7sguviM=";
  };
  "src/third_party/zlib" = fetchFromGoogle {
    owner = "chromium";
    repo = "chromium/src/third_party/zlib";
    rev = "27c2f474b71d0d20764f86f60ef8b00da1a16cda";
    sha256 = "sha256-R+NQpULH7BO9udKqoOFSkMdCl+L8Gx1Q5eDA621SIc0=";
  };
}
