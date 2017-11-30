{ stdenv, fetchFromGitHub, thrift, python2, python2Packages }:

python2.pkgs.buildPythonPackage rec {
  pname = "p4c-bm";
  version = "1.9.0";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "p4lang";
    repo = "p4c-bm";
    rev = version;
    sha256 = "1kb6rcc79mm60hv36nnvssv903cvjih0s9bcz2xzhq6f6d7b09an";
  };

  patches = [
    ./0001-setup.py-remove-CustomInstall-and-CustomInstallScrip.patch
    ./0001-setup.py-use-py.test.patch
  ];

  nativeBuildInputs = [ ];
  buildInputs = [  ];
  propagatedBuildInputs = [ thrift python2Packages.tenjin python2Packages.p4-hlir ]; # python libs need to be propagated
  checkInputs = with python2Packages; [ pytest ];

  # TODO: according to the website, p4-hlir only supports P4_14 version of the P4 programming language.
  # But it looks like it is still needed.
  # TODO: remove requirements.txt upstream
  postFixup = ''
    substituteInPlace requirements.txt --replace "git+https://github.com/p4lang/p4-hlir.git#egg=p4-hlir" ""
  '';

  checkPhase = "py.test -x -v -k 'not test_main'";
  doCheck = true;

  meta = with stdenv.lib; {
    license = licenses.asl20;
    homepage = https://github.com/p4lang/behavioral-model;
    description = "Generates the JSON configuration for the behavioral-model (bmv2), as well as the C/C++ PD code";
    platforms = platforms.linux;
  };
}
