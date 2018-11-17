{ stdenv, symlinkJoin, makeWrapper, virtualbox, virtualboxExtpack }:

symlinkJoin {
  name = "virtualbox-wrapped-${virtualbox.version}";

  paths = [ virtualbox ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''\
    for file in $(find $out/bin/*); do
      echo wrapProgram $file --set VBOX_EXTPACK_DIR ${virtualboxExtpack}
      wrapProgram $file --set VBOX_EXTPACK_DIR ${virtualboxExtpack}
    done
  '';

  inherit (virtualbox) meta version;
}
