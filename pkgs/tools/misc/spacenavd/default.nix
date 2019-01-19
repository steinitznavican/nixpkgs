{ stdenv, fetchFromGitHub, gnumake, xorg }:

let
  name = "spacenavd";
  version = "0.6";
in
stdenv.mkDerivation rec {
  inherit name version;

  src = fetchFromGitHub {
    owner = "FreeSpaceNav";
    repo = name;
    rev = "${name}-${version}";
    sha256 = "0vf6c6gzkg0ix89fy2zz03yhsgpzwxabqyy216ylhigrys9ak090";
  };

  nativeBuildInputs = [ gnumake ];
  buildInputs = [ xorg.libX11 ];

  # TODO decide about spnavd_ctl which sends SIGUSR1 and SIGUSR2

  meta = with stdenv.lib; {
    description = "Free user-space driver for 6-dof space-mice";
    homepage = http://spacenav.sourceforge.net/;
    license = licenses.gpl3;
    maintainers = with maintainers; [ flokli ];
    platforms = platforms.linux;
  };
}
