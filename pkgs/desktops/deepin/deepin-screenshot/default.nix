{ stdenv, fetchFromGitHub, pkgconfig, cmake, dtkcore, dtkwidget,
  qtx11extras, deepin, dtkwm }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "deepin-screenshot";
  version = "4.1.4";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "1zw057gqqizf2r0vwhwc06rwjzhafanf68va4lkswm1k3qf4wpcj";
  };

  nativeBuildInputs = [
    pkgconfig
    cmake
    qtx11extras
  ];

  buildInputs = [
    dtkcore
    dtkwidget
    dtkwm
  ];

  enableParallelBuilding = true;

  passthru.updateScript = deepin.updateScript { inherit name; };

  meta = with stdenv.lib; {
    description = "Sophisticated screenshot software developed by deepin technology team";
    homepage = https://github.com/linuxdeepin/deepin-screenshot;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ romildo flokli ];
  };
}
