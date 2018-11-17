{ stdenv, fetchurl, lib }:

let name = "Oracle_VM_VirtualBox_Extension_Pack";
  version = "5.2.14";
  extpackRev = "123301";
in

stdenv.mkDerivation {
  inherit name version;

  src = fetchurl {
    url = "http://download.virtualbox.org/virtualbox/${version}/${name}-${version}-${toString extpackRev}.vbox-extpack";
    sha256 = "d90c1b0c89de19010f7c7fe7a675ac744067baf29a9966b034e97b5b2053b37e";
  };

  unpackCmd = ''
    mkdir -p out
    tar xf $curSrc -C out
  '';
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/${name}
    cp -R * $out/${name}/
  '';

  meta = with stdenv.lib; {
    description = "Oracle Extension pack for VirtualBox";
    license = licenses.virtualbox-puel;
    homepage = https://www.virtualbox.org/;
    maintainers = with maintainers; [ flokli sander cdepillabout ];
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
