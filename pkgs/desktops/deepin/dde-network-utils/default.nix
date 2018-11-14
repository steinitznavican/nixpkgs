{ stdenv, fetchFromGitHub, qmake, pkgconfig, qttools,
  dde-qt-dbus-factory, proxychains, which, deepin }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "dde-network-utils";
  version = "0.0.8.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "0mfdi5brcnqmkgfzzjwlkdvpf8xm7sgrg5h23k6qbr2mpj6337j4";
  };

  nativeBuildInputs = [
    qmake
    pkgconfig
    qttools
    deepin.setupHook
  ];

  buildInputs = [
    dde-qt-dbus-factory
    proxychains
    which
  ];

  postPatch = ''
    searchHardCodedPaths
    patchShebangs .
    fixPath ${proxychains} /usr/bin/proxychains4 networkworker.cpp
  '';

  passthru.updateScript = deepin.updateScript { inherit name; };

  meta = with stdenv.lib; {
    description = "DDE network utils";
    homepage = https://github.com/linuxdeepin/dde-network-utils;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ romildo ];
  };
}
