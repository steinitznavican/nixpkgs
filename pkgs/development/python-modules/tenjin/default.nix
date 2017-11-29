{ stdenv, buildPythonPackage, isPy3k, fetchPypi, pytest, pyyaml }:

buildPythonPackage rec {
  pname = "Tenjin";
  version = "1.1.1";
  name = "${pname}-${version}";

  disabled = isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "15s681770h7m9x29kvzrqwv20ncg3da3s9v225gmzz60wbrl9q55";
  };

  propagatedBuildInputs = [ pyyaml ];

  checkInputs = [ pytest ];
  checkPhase = "py.test";

  meta = with stdenv.lib; {
    description = "A fast and full-featured template engine based on embedded Python";
    homepage = https://pypi.python.org/pypi/Tenjin/;
    license = licenses.mit;
  };
}
