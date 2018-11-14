{ stdenv, fetchFromGitHub, cmake, pkgconfig, qttools, qtx11extras,
  qtsvg, libsForQt5, gsettings-qt, dtkcore, dtkwidget,
  dde-qt-dbus-factory, dde-network-utils, dde-daemon, xorg, deepin }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "dde-dock";
  version = "4.8.4";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "0ppabdv0w8j0r9s1v36pymc5my69qcspndjnm5z8ghn7grzdknb9";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    deepin.setupHook
  ];

  buildInputs = [
    dde-daemon
    dde-network-utils
    dde-qt-dbus-factory
    dtkcore
    dtkwidget
    gsettings-qt
    libsForQt5.libdbusmenu
    qtsvg
    qtx11extras
    xorg.libXdmcp
    xorg.libXtst
    xorg.libpthreadstubs
  ];

  postPatch = ''
    echo ==============================================
    find -name "*.cmake" -ls
    echo ==============================================
    searchHardCodedPaths
    patchShebangs .
    fixPath ${dde-daemon}        /usr/lib/deepin-daemon       frame/item/showdesktopitem.cpp
    fixPath ${dde-network-utils} /usr/share/dde-network-utils frame/main.cpp
    fixPath $out                 /usr/bin/dde-dock            frame/com.deepin.dde.Dock.service
    fixPath $out                 /usr/share/dbus-1            CMakeLists.txt
    fixPath $out                 /etc/dde-dock                plugins/keyboard-layout/CMakeLists.txt
    fixPath $out                 /usr                         dde-dock.pc
  '';

  passthru.updateScript = deepin.updateScript { inherit name; };

  meta = with stdenv.lib; {
    description = "Dock for Deepin Desktop Environment";
    homepage = https://github.com/linuxdeepin/dde-dock;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ romildo ];
  };
}
