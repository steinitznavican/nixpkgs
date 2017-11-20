{stdenv, fetchurl, autoreconfHook, pkgconfig, libtool, python2Packages, glib, jansson}:

stdenv.mkDerivation rec
{
  version = "3.0.7";
  seafileVersion = "6.1.0";
  name = "libsearpc-${version}";

  src = fetchurl
  {
    url = "https://github.com/haiwen/libsearpc/archive/v${version}.tar.gz";
    sha256 = "0fdrgksdwd4qxp7qvh75y39dy52h2f5wfjbqr00h3rwkbx4npvpg";
  };

  patches = [ ./libsearpc.pc.patch ];

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ libtool python2Packages.python python2Packages.simplejson ];
  propagatedBuildInputs = [ glib jansson ];

  meta = with stdenv.lib; {
    homepage = https://github.com/haiwen/libsearpc;
    description = "A simple and easy-to-use C language RPC framework (including both server side & client side) based on GObject System";
    license = licenses.lgpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.calrama ];
  };
}
