{ stdenv, buildGoPackage, fetchFromGitHub, curl, libgit2, git, ncurses, makeWrapper, pkgconfig, readline }:
let
  version = "0.2.0";
  wrapperPath = stdenv.lib.makeBinPath ([ git ]);
in
buildGoPackage {
  name = "grv-${version}";

  buildInputs = [ ncurses readline curl libgit2 ];
  nativeBuildInputs = [ makeWrapper pkgconfig ];

  goPackagePath = "github.com/rgburke/grv";

  src = fetchFromGitHub {
    owner = "rgburke";
    repo = "grv";
    rev = "v${version}";
    sha256 = "0hlqw6b51jglqzzjgazncckpgarp25ghshl0lxv1mff80jg8wd1a";
    fetchSubmodules = true;
  };

  buildFlagsArray = [ "-ldflags=" "-X main.version=${version}" ];

  postFixup = ''
    wrapProgram $out/bin/grv \
      --prefix PATH : "${wrapperPath}"
  '';

  meta = with stdenv.lib; {
    description = " GRV is a terminal interface for viewing git repositories";
    homepage = https://github.com/rgburke/grv;
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ andir ];
  };
}
