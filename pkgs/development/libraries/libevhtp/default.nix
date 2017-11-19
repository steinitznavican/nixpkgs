{ stdenv, fetchFromGitHub, cmake, libevent, openssl, oniguruma }:

stdenv.mkDerivation rec {
  name = "libevhtp-${version}";
  version = "1.2.14";

  src = fetchFromGitHub {
    owner = "criticalstack";
    repo = "libevhtp";
    sha256 = "03m2vs35vkp83gfk7ipjj89fs21ddc8gpas5di54xmad1n753jsh";
    rev = version;
  };

  buildInputs = [ libevent openssl oniguruma ];
  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DEVHTP_DISABLE_SSL=OFF" "-DEVHTP_BUILD_SHARED=ON" ];

  meta = with stdenv.lib; {
    homepage = https://github.com/criticalstack/libevhtp/;
    description = "Create extremely-fast and secure embedded HTTP servers with ease.";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = [ maintainers.flokli ];
  };
}
