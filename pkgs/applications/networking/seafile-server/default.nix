{ stdenv, fetchurl, writeScript, pkgconfig, autoreconfHook, seafile-shared, ccnet, libuuid, openssl, glib, python, fuse, libarchive, oniguruma, libevhtp, libsearpc, vala, lzma, bzip2, makeWrapper }:

stdenv.mkDerivation rec {
  version = "6.2.3";
  name = "seafile-server-${version}";

  src = fetchurl {
    url = "https://github.com/haiwen/seafile-server/archive/v${version}-server.tar.gz";
    sha256 = "04f1iihq34vxx4y39d06ibjgcgs5flwnpr4nvy75hdvx0fhcigvp";
  };
  patches = [
    ./makefiles.patch
    ./pkg-check-modules.patch
    ./libseafile.in.patch
    ./configure_evhtp.patch
    ./configure_oniguruma.patch
    (fetchurl {
      url = "https://sml.zincube.net/~niol/repositories.git/seafile-server/plain/debian/patches/recent-libevhtp";
      sha256 = "0fwvkg6f1h3nwjkcl0jpia9c5zx1jcrbhv8kzvp2q6vlbx6cipv3";
    })
    (fetchurl {
      url = "https://sml.zincube.net/~niol/repositories.git/seafile-server/plain/debian/patches/newer-libevhtp";
      sha256 = "0p8bhsrcwdymjfsh5gacvf4kkgbsn9vi4hq0s22rijg2m7qc0z5r";
    })
  ];

  postPatch = ''
    substituteInPlace ./lib/Makefile.am \
      --replace "\`which searpc-codegen.py\`" ${libsearpc}/bin/searpc-codegen.py
  '';

  nativeBuildInputs = [ pkgconfig vala autoreconfHook makeWrapper ];
  buildInputs = [ libuuid openssl glib ccnet python fuse libarchive oniguruma libevhtp libsearpc lzma bzip2 ];

  #postInstall = ''
  #  wrapProgram $out/bin/seafile-applet \
  #    --suffix PATH : ${stdenv.lib.makeBinPath [ ccnet seafile-shared ]}
  #'';

  meta = with stdenv.lib; {
    homepage = https://github.com/haiwen/seafile-server;
    description = "Server Core for Seafile, the Next-generation Open Source Cloud Storage";
    license = licenses.agpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.flokli ];
  };
}
