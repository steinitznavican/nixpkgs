{ stdenv, lib, fetchurl, cmake, ninja, pkgconfig, libiconv, libintl
, zlib, curl, cairo, freetype, fontconfig, lcms, libjpeg, openjpeg
, gobjectIntrospection, qt5
, withData ? true, poppler_data
}:

let # beware: updates often break cups-filters build
  version = "0.63.0";
  mkFlag = optset: flag: "-DENABLE_${flag}=${if optset then "on" else "off"}";
in
stdenv.mkDerivation rec {
  name = "poppler-${version}";

  src = fetchurl {
    url = "${meta.homepage}/poppler-${version}.tar.xz";
    sha256 = "04d1z1ygyb3llzc6s6c99wxafvljj2sc5b76djif34f7mzfqmk17";
  };

  outputs = [ "out" "dev" "qt5" "glib" "utils" ];

  buildInputs = [ libiconv libintl ] ++ lib.optional withData poppler_data;

  # TODO: reduce propagation to necessary libs
  propagatedBuildInputs = with lib;
    [ zlib freetype fontconfig libjpeg openjpeg ]
    ++ [ cairo lcms curl ]
    ++ [ qt5.qtbase ]
    ++ [ gobjectIntrospection ];

  nativeBuildInputs = [ cmake ninja pkgconfig ];

  # Not sure when and how to pass it.  It seems an upstream bug anyway.
  CXXFLAGS = stdenv.lib.optionalString stdenv.cc.isClang "-std=c++11";

  cmakeFlags = [
    (mkFlag true "XPDF_HEADERS")
    (mkFlag true "GLIB") # TODO output
    (mkFlag true "CPP")
    (mkFlag true "LIBCURL")
    (mkFlag true "UTILS") #TODO output
    (mkFlag true "QT5") # TODO output, qt4?
  ];

  postInstall = ''
    find $out

    # glib
    moveToOutput $out/include/poppler/glib $glib/include/poppler/
    moveToOutput $out/lib/libpoppler-glib.* $glib/lib/
    moveToOutput $out/lib/pkgconfig/poppler-glib.pc $glib/lib/pkgconfig/
    moveToOutput $out/lib/girepository-* $glib/lib/
    moveToOutput $out/share/gir-* $glib/share/

    # utils
    moveToOutput $out/bin $utils/

    # qt5
    moveToOutput $out/include/poppler/qt5 $qt5/include/poppler/
    moveToOutput $out/lib/libpoppler-qt5.* $qt5/lib
    moveToOutput $out/lib/pkgconfig/poppler-qt5.pc $qt5/lib/pkgconfig/
  '';

  meta = with lib; {
    homepage = https://poppler.freedesktop.org/;
    description = "A PDF rendering library";

    longDescription = ''
      Poppler is a PDF rendering library based on the xpdf-3.0 code base.
    '';

    license = licenses.gpl2;
    platforms = platforms.all;
    maintainers = with maintainers; [ ttuegel ];
  };
}
