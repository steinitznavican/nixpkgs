{ stdenv, fetchFromGitHub, rustPlatform, pkgconfig, openssl }:

let
  version = "3.0.2";
in rustPlatform.buildRustPackage rec {
  name = "coreos-metadata-${version}";

  src = fetchFromGitHub {
    owner = "coreos";
    repo = "coreos-metadata";
    rev = "v${version}";
    sha256 = "04i38mijy2dhh1mjiaazkf2lmm0vmhcsp42i6d3f6hq5kk012fq3";
  };

  cargoSha256 = "0xw59icgar5nz8ri6xdfh144wvkzkricr2pl04vj0gh2slsjg1iz";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ openssl ];

  meta = {
    description = "A simple cloud-provider metadata agent";
    homepage = https://github.com/coreos/coreos-metadata;
    license = stdenv.lib.licenses.asl20;
    platforms = stdenv.lib.platforms.linux;
  };
}
