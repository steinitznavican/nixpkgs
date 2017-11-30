{ stdenv, fetchFromGitHub, thrift, python2, python2Packages }:

python2.pkgs.buildPythonPackage rec {
  pname = "p4-hlir";
  version = "0.0.1"; # no real release yet…
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "p4lang";
    repo = "p4-hlir";
    rev = "master";
    sha256 = "1abd96wj2xrjbmvwzjrrr0wh6cs0kd28m189zfrc5j76113zc7ag";
  };

  patches = [
    ./0001-hlir-setup.py-remove-CustomInstall-and-CustomInstallScrip.patch
    ./0002-hlir-setup.py-use-py.test.patch
  ];

  nativeBuildInputs = [ ];
  buildInputs = [  ];
  propagatedBuildInputs = [ python2Packages.ply ];

  # no idea how to run the tests…
  doCheck = false;

  meta = with stdenv.lib; {
    license = licenses.asl20;
    homepage = https://github.com/p4lang/p4-hlir/;
    description = "p4-hlir supports the P4_14 version of the P4 programming language.";
    platforms = platforms.linux;
  };
}
