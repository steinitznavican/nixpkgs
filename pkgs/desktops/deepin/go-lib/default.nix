{ stdenv, fetchFromGitHub, glib, xorg, gdk_pixbuf, pulseaudio,
  mobile-broadband-provider-info, deepin }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "go-lib";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "0lkyzlbxmq1mw0g3pqr5sasb6zr4rl9vb49907zq61aqhgk5dgb6";
  };

  buildInputs = [
    glib
    xorg.libX11
    gdk_pixbuf
    pulseaudio
    mobile-broadband-provider-info
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "GOSITE_DIR=$(out)/share/go"
  ];

  passthru.updateScript = deepin.updateScript { inherit name; };

  meta = with stdenv.lib; {
    description = "Go bindings for Deepin Desktop Environment development";
    homepage = https://github.com/linuxdeepin/go-lib;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ romildo ];
  };
}
