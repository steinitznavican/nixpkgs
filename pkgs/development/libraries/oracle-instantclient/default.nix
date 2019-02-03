{ stdenv, fetchurl, requireFile, autoPatchelfHook, fixDarwinDylibNames, unzip, rpmextract, libaio, makeWrapper, odbcSupport ? false, unixODBC, licenseAccepted ? false }:

assert odbcSupport -> unixODBC != null;

if !licenseAccepted then throw ''
  You must accept the Oracle Technology Network License Agreement at
  https://www.oracle.com/technetwork/licenses/distribution-license-152002.html
  by setting nixpkgs config option 'otn.accept_license = true;'
  ''
else assert licenseAccepted;

let
  inherit (stdenv.lib) optional optionals optionalString;

  baseVersion = "18.3";
  version = "${baseVersion}.0.0.0";
  rel = "3";

  fetchOracle = component: arch: version: rel: hash:
  if arch == "linux.x64" then
    let
      component' = if component == "sdk" then "devel" else component;
    in
    # fetch the click-through rpm
    (fetchurl {
      url = "http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/" +
      "oracle-instantclient${baseVersion}-${component'}-${version}" + (optionalString (rel != "") "-${rel}") + ".x86_64.rpm";
      sha256 = hash;
    }) else (requireFile rec {
      name = "instantclient-${component}-${arch}-${version}" + (optionalString (rel != "") "-${rel}") + ".zip";
      url = "http://www.oracle.com/technetwork/database/database-technologies/instant-client/downloads/index.html";
      sha256 = hash;
    });
  throwSystem = throw "Unsupported system: ${stdenv.hostPlatform.system}";

  arch = {
    "x86_64-linux" = "linux.x64";
    "x86_64-darwin" = "macos.x64";
  }."${stdenv.hostPlatform.system}" or throwSystem;

  srcs = {
    "x86_64-linux" = [
      (fetchOracle "basic" arch version rel "1d8ml0sjrpg6fg20yrrakr8v8g17xr20fbpwc3ai68aqkpalkfqd")
      (fetchOracle "sdk" arch version rel "1z21kwnfxjyvgvcggm0bfl83hb5r9vzd9pqy8v6nryapx1yyhh6r")
      (fetchOracle "sqlplus" arch version rel "0nih355ggs7c2gjnqjzzvc5pprz18rjwz1ryn8gq43p931ib54ja") ]
      ++ optional odbcSupport (fetchOracle "odbc" arch version rel "1hd2ngqzbg2fvlxig8l04fzg0vbpfcl8bx9wfrgvc8dmir059mmx");
    "x86_64-darwin" = [
      (fetchOracle "basic" arch version rel "0000000000000000000000000000000000000000000000000000000000000000")
      (fetchOracle "sdk" arch version rel "0000000000000000000000000000000000000000000000000000000000000000")
      (fetchOracle "sqlplus" arch version rel "0000000000000000000000000000000000000000000000000000000000000000") ]
      ++ optional odbcSupport (fetchOracle "odbc" arch version rel "0000000000000000000000000000000000000000000000000000000000000000");
  }."${stdenv.hostPlatform.system}" or throwSystem;

  extLib = stdenv.hostPlatform.extensions.sharedLibrary;
in stdenv.mkDerivation rec {
  inherit version srcs;
  name = "oracle-instantclient-${version}";

  buildInputs = [ stdenv.cc.cc.lib ]
    ++ optionals (stdenv.isLinux) [ libaio ]
    ++ optional odbcSupport unixODBC;

  nativeBuildInputs = [ makeWrapper ]
    ++ optional stdenv.isLinux autoPatchelfHook
    ++ optional stdenv.isDarwin fixDarwinDylibNames;

    unpackCmd = if stdenv.hostPlatform.system == "x86_64-linux" then
    # RPM files contain files inside /usr/*/oracle/${baseVersion},
    # so massage it to match the zip layout
    ''
      ${rpmextract}/bin/rpmextract $curSrc
      mkdir -p instantclient
      for f in "usr/lib/oracle/${baseVersion}/client64/"{bin,lib}/* ; do
        mv $f instantclient
      done
      for f in "usr/share/oracle/${baseVersion}/"{client64/,}"doc/"* ; do
        mv $f instantclient
      done

      mkdir -p instantclient/sdk/{include,demo}
      for f in "usr/include/oracle/${baseVersion}/client64/"* ; do
        mv $f instantclient/sdk/include/
      done
      for f in "usr/share/oracle/${baseVersion}/client64/demo/"* ; do
        mv $f instantclient/sdk/demo/
      done

      rm -R usr
    ''
    else "${unzip}/bin/unzip $curSrc";

  installPhase = ''
    mkdir -p "$out/"{bin,include,lib,"share/java","share/${name}/demo/"}
    install -Dm755 {sqlplus,adrci,genezi} $out/bin
    ${optionalString stdenv.isDarwin ''
      for exe in "$out/bin/"* ; do
        install_name_tool -add_rpath "$out/lib" "$exe"
      done
    ''}
    ln -sfn $out/bin/sqlplus $out/bin/sqlplus64
    install -Dm644 *${extLib}* $out/lib
    install -Dm644 *.jar $out/share/java
    install -Dm644 sdk/include/* $out/include
    install -Dm644 sdk/demo/* $out/share/${name}/demo

    # PECL::oci8 will not build without this
    # this symlink only exists in dist zipfiles for some platforms
    ln -sfn $out/lib/libclntsh${extLib}.12.1 $out/lib/libclntsh${extLib}
  '';

  meta = with stdenv.lib; {
    homepage = http://www.oracle.com/technetwork/database/database-technologies/instant-client/downloads/index.html;
    description = "Oracle instant client libraries and sqlplus CLI";
    longDescription = ''
      Oracle instant client provides access to Oracle databases (OCI,
      OCCI, Pro*C, ODBC or JDBC). This package includes the sqlplus
      command line SQL client.
    '';
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    maintainers = with maintainers; [ pesterhazy flokli ];
    hydraPlatforms = [];
  };
}
