{ stdenv, fetchurl, networkmanager, pptp, ppp, intltool, pkgconfig
, libsecret, withGnome ? true, gnome3 }:

stdenv.mkDerivation rec {
  name    = "${pname}${if withGnome then "-gnome" else ""}-${version}";
  pname   = "NetworkManager-pptp";
  major   = "1.2";
  version = "${major}.4";

  src = fetchurl {
    url    = "mirror://gnome/sources/${pname}/${major}/${pname}-${version}.tar.xz";
    sha256 = "bd97ce768c34cce6d5b5d43681149a8300bec754397a3f46a0d8d0aea7030c5e";
  };

  buildInputs = [ networkmanager pptp ppp libsecret ]
    ++ stdenv.lib.optionals withGnome [ gnome3.gtk gnome3.libgnome_keyring
                                        gnome3.networkmanagerapplet ];

  nativeBuildInputs = [ intltool pkgconfig ];

  patches = [ ./nm-pptp-service-remove-manual-path-calculations-use-.patch ];

  configureFlags =
    if withGnome then "--with-gnome --with-gtkver=3" else "--without-gnome";

  meta = {
    description = "PPtP plugin for NetworkManager";
    inherit (networkmanager.meta) maintainers platforms;
  };
}
