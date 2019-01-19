{ stdenv, fetchFromGitHub, gnumake, xorg }:

let
  name = "libspnav";
  version = "0.2.3";
in
stdenv.mkDerivation rec {
  inherit name version;

  src = fetchFromGitHub {
    owner = "FreeSpaceNav";
    repo = name;
    rev = "${name}-${version}";
    sha256 = "098h1jhlj87axpza5zgy58prp0zn94wyrbch6x0s7q4mzh7dc8ba";
  };

  nativeBuildInputs = [ gnumake ];
  buildInputs = [ xorg.libX11 ];

  meta = with stdenv.lib; {
    description = "Library for communicating with spacenavd or 3dxsrv to get input from 6-dof devices.";
    homepage = http://spacenav.sourceforge.net/;
    license = licenses.bsd3;
    maintainers = with maintainers; [ flokli ];
    platforms = platforms.linux;
  };
}
