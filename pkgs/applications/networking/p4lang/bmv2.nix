{ stdenv, fetchFromGitHub, fetchpatch, autoreconfHook, bash, cmake, pkgconfig,
  makeWrapper, flex, bison, judy, gmp, libpcap, boost, libevent, libtool, openssl,
  thrift, nanomsg, python2
}:

python2.pkgs.buildPythonPackage rec {
  pname = "bmv2";
  version = "1.9.1";
  name = "${pname}-${version}";

  format = "other";

  src = fetchFromGitHub {
    owner = "p4lang";
    repo = "behavioral-model";
    rev = version;
    sha256 = "1amdsp8f8adk7s58l5m6p49hij3d7y38vg67c93bp4gxa3bv9j8x";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig makeWrapper flex bison ];
  buildInputs = [ judy gmp libpcap boost /*boost-test (?) */
                  libevent libtool openssl /*python2*/
                  # TODO: undocumented:
                  # TODO: use system jsoncpp if available
                  nanomsg ];
  propagatedBuildInputs = [ thrift ];

  patches = [
    (fetchpatch {
      name = "bm_runtime-add-missing-iostream-include.patch";
      url = https://github.com/p4lang/behavioral-model/commit/9f22fd5307f17872e99e816ab968bff8d5764abc.patch;
      sha256 = "0v9bk80l0jalwxlg94vp9b9x1nl5srabrhqx6k49nycp3qai4zg7";
    })
  ];

  postUnpack = ''
    for f in source/tools/*.sh source/tests/*/*.sh source/targets/simple_switch/sswitch_CLI; do
      substituteInPlace $f --replace "/bin/bash" "${bash}/bin/bash"
    done
  '';

  installFlags = ''
    pythondir="$(out)/lib/${python2.libPrefix}/site-packages"
  '';

  meta = with stdenv.lib; {
    license = licenses.asl20;
    homepage = https://github.com/p4lang/behavioral-model;
    description = "Behavioral model for p4lang";
    platforms = platforms.linux;
  };
}
