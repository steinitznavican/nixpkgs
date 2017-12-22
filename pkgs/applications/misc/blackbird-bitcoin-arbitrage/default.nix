{ stdenv, fetchFromGitHub, fetchpatch, openssl, jansson, curl, sqlite, cmake }:

let
  version = "2017-12-13";
in
stdenv.mkDerivation {
  name = "blackbird-bitcoin-arbitrage-${version}";

  src = fetchFromGitHub {
    owner = "butor";
    repo = "blackbird";
    rev = "8038094f037ba58a69141a1a9dc6936261a7d498";
    sha256 = "0h8liighdck2zxkz4y5552rdpg1yndlkn4j2h80psq2s3s7splgx";
  };

  patches = [(fetchpatch {
    sha256 = "045i7wsy290px16y2cjvfw8sjqrhq0r8vq7i8xzfx5zny4si9qxv";
    url = https://github.com/flokli/blackbird/commit/1d7bfab806f27855ae4c207aee5b8126635d97a6.patch;
  })
 ];

  # TODO: sendEmail
  buildInputs = [ openssl jansson curl sqlite ];
  nativeBuildInputs = [ cmake ];

  #cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];

  meta = with stdenv.lib; {
    description = "C++ trading system that does automatic long/short arbitrage between Bitcoin exchanges";
    homepage = https://github.com/butor/blackbird;
    license = licenses.lgpl3;
    #    platforms = ;
    maintainers = with maintainers; [ flokli ];
  };
}
