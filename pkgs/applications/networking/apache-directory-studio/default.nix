{ stdenv, fetchurl, undmg, xorg, jre, jdk8, autoPatchelfHook, makeWrapper, makeDesktopItem, xmlstarlet }:

let
  rpath = stdenv.lib.makeLibraryPath (with xorg; [
    libXtst
  ]);

  desktopItem = makeDesktopItem {
    name = "apache-directory-studio";
    exec = "ApacheDirectoryStudio";
    icon = "apache-directory-studio";
    comment = "Eclipse-based LDAP browser and directory client";
    desktopName = "Apache Directory Studio";
    genericName = "Apache Directory Studio";
    categories = "Java;Network";
  };

  throwSystem = throw "Unsupported system: ${stdenv.system}";

  name = "apache-directory-studio-${version}";
  version = "2.0.0.v20170904-M13";
  src = {
    "x86_64-linux" = fetchurl {
      url = "mirror://apache/directory/studio/${version}/ApacheDirectoryStudio-${version}-linux.gtk.x86_64.tar.gz";
      sha256 = "1jfnm6m0ijk31r30hhrxxnizk742dm317iny041p29v897rma7aq";
    };
    "i686-linux" = fetchurl {
      url = "mirror://apache/directory/studio/${version}/ApacheDirectoryStudio-${version}-linux.gtk.x86.tar.gz";
      sha256 = "1bxmgram42qyhrqkgp5k8770f5mjjdd4c6xl4gj09smiycm1qa4n";
    };
    "x86_64-darwin" = fetchurl {
      url = "mirror://apache/directory/studio/${version}/ApacheDirectoryStudio-${version}-macosx.cocoa.x86_64.dmg";
      sha256 = "1hsxq66dc8zhkqllwipahgigi8b17r39whsig9rk8w1i6nbhdpqp";
    };
  }."${stdenv.system}" or throwSystem;

in stdenv.mkDerivation rec {
  inherit name version src;

  nativeBuildInputs = [ makeWrapper ]
    ++ stdenv.lib.optionals (!stdenv.isDarwin) [ autoPatchelfHook ]
    ++ stdenv.lib.optionals stdenv.isDarwin [ undmg xmlstarlet ];

  installPhase = if (! stdenv.isDarwin) then ''
    mkdir -p $out/libexec
    cp -r . $out/libexec/

    makeWrapper $out/libexec/ApacheDirectoryStudio $out/bin/ApacheDirectoryStudio \
        --prefix LD_LIBRARY_PATH : "${rpath}" \
        --prefix PATH : "${jre}/bin"
    install -D icon.xpm "$out/share/pixmaps/apache-directory-studio.xpm"
    install -D -t "$out/share/applications" ${desktopItem}/share/applications/*
    '' else ''
    mkdir -p "$out/Applications/${name}.app"
    cp -R . "$out/Applications/${name}.app"
    chmod a+x "$out/Applications/${name}.app/Contents/MacOS/ApacheDirectoryStudio"

    # add -vm ${jre}/bin to plist
    xml ed -a '/plist/dict/key[normalize-space(text())="Eclipse"]/following::array/string[last()]' -t elem -n string -v '-vm' ./Contents/Info.plist | \
    xml ed -a '/plist/dict/key[normalize-space(text())="Eclipse"]/following::array/string[last()]' -t elem -n string -v '${jdk8.home}/bin/java' > $out/Applications/${name}.app/Contents/Info.plist

    #wrapProgram $out/Applications/${name}.app/Contents/MacOS/ApacheDirectoryStudio \
    #  --prefix PATH : ${jre}/bin \
    #  --set JAVA_HOME ${jre} \
    #'';

  meta = with stdenv.lib; {
    description = "Eclipse-based LDAP browser and directory client";
    homepage = "https://directory.apache.org/studio/";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "i686-linux" "x86_64-darwin" ];
    maintainers = [ maintainers.bjornfor ];
  };
}
