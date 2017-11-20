{stdenv, fetchurl, which, autoreconfHook, pkgconfig, vala_0_23, python, libsearpc, libzdb, libuuid, libevent, sqlite, openssl}:

stdenv.mkDerivation rec
{
  version = "6.1.0";
  name = "ccnet-${version}";

  src = fetchurl {
    url = "https://github.com/haiwen/ccnet/archive/v${version}.tar.gz";
    sha256 = "0q4a102xlcsxlr53h4jr4w8qzkbzvm2f3nk9fsha48h6l2hw34bb";
  };

  nativeBuildInputs = [ pkgconfig autoreconfHook which ];
  buildInputs = [ vala_0_23 python ];
  propagatedBuildInputs = [ libsearpc libzdb libuuid libevent sqlite openssl ];

  meta = with stdenv.lib; {
    homepage = https://github.com/haiwen/ccnet;
    description = "A framework for writing networked applications in C";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ maintainers.calrama ];
  };
}
