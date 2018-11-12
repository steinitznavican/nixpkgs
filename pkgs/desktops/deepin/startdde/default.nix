{ stdenv, buildGoPackage, fetchFromGitHub, pkgconfig, gnome3, alsaLib,
  pulseaudio, libX11, libXi, gtk3, libgnome-keyring, jq,
  go-dbus-factory, go-gir-generator, go-lib, dde-api, dbus-factory,
  dde-daemon, deepin-metacity, deepin-wm, go, deepin, coreutils,
  deepin-desktop-base, deepin-desktop-schemas, kmod, dde-session-ui,
  dde-dock, deepin-turbo, dde-polkit-agent, libcgroup, pciutils,
  wrapGAppsHook }:

let
   dde-file-manager = "";
in

buildGoPackage rec {
  name = "${pname}-${version}";
  pname = "startdde";
  version = "3.6.0";

  goPackagePath = "pkg.deepin.io/dde/startdde";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "19myxg6kjsyl1d6szv1nmkni1ndadhn1xdlhsr3dkmgg87vcqmcd";
  };

  goDeps = ./deps.nix;

  outputs = [ "out" ];

  nativeBuildInputs = [
    pkgconfig
    dbus-factory
    go-dbus-factory
    go-gir-generator
    go-lib
    dde-api
    jq
    wrapGAppsHook
    deepin.setupHook
  ];

  buildInputs = [
    alsaLib
    dde-daemon
    dde-dock
    dde-polkit-agent
    dde-session-ui
    deepin-desktop-schemas
    deepin-metacity
    deepin-turbo
    deepin-wm
    gnome3.dconf
    gtk3
    libX11
    libXi
    libcgroup
    libgnome-keyring
    pciutils
    pulseaudio
  ];

  postPatch = ''
    searchHardCodedPaths
    patchShebangs .
     fixPath ${coreutils}           /bin/ls                                   copyfile_test.go
     fixPath ${deepin-desktop-base} /etc/deepin-version                       session.go
    #fixPath ?                      /etc/deepin-wm-switcher/config.json       wm/switcher_config.go
    #fixPath ?                      /etc/xdg/autostop                         autostop/autostop.go
     fixPath ${kmod}                /sbin/lsmod                               wm/driver.go
    #fixPath ${dde-file-manager}    /usr/bin/dde-desktop                      misc/auto_launch/default.json misc/auto_launch/chinese.json
     fixPath ${dde-dock}            /usr/bin/dde-dock                         misc/auto_launch/default.json misc/auto_launch/chinese.json
    #fixPath ${dde-file-manager}    /usr/bin/dde-file-manager                 misc/auto_launch/chinese.json
     fixPath ${dde-session-ui}      /usr/bin/dde-shutdown                     session.go
     fixPath ${dde-session-ui}      /usr/lib/deepin-daemon/dde-welcome        utils.go
     fixPath ${dde-session-ui}      /usr/lib/deepin-daemon/dde-osd            session.go
     fixPath ${dde-daemon}          /usr/lib/deepin-daemon/dde-session-daemon misc/auto_launch/default.json misc/auto_launch/chinese.json
     fixPath ${pulseaudio}          /usr/bin/pulseaudio                       sound_effect.go
     fixPath ${libgnome-keyring}    /usr/bin/gnome-keyring-daemon             session.go
    #fixPath ?                      /usr/lib/UIAppSched.hooks                 startmanager.go
     fixPath ${deepin-turbo}        /usr/lib/deepin-turbo/booster-dtkwidget   misc/auto_launch/chinese.json
    #fixPath ?                      /usr/lib/lightdm/config-error-dialog.sh   misc/deepin-session
     fixPath ${dde-polkit-agent}    /usr/lib/polkit-1-dde/dde-polkit-agent    watchdog/dde_polkit_agent.go
    #fixPath ?                      /usr/sbin/lightdm-session                 misc/deepin-session
     fixPath $out                   /usr/bin/startdde                         misc/deepin-session
     fixPath $out                   /usr/sbin/deepin-session                  misc/lightdm.conf
     fixPath $out                   /usr/sbin/deepin-fix-xauthority-perm      misc/lightdm.conf
     fixPath $out                   /usr/share/startdde/auto_launch.json      launch_group.go
    #fixPath $out                   /usr/share/startdde/memchecker.json       memchecker/config.go
    #fixPath ?                      /var/log/Xorg.0.log                       wm/driver.go

    echo ___________; (grep --color=always -r -E '/(usr|bin|sbin|etc|var|opt)\>' || true)
    echo ___________
  '';

  buildPhase = ''
    make -C go/src/${goPackagePath}
  '';

  installPhase = ''
    make install PREFIX="$out" -C go/src/${goPackagePath}
    remove-references-to -t ${go} $out/bin/* $out/sbin/*

    # debugging
    echo -----------; (grep --color=always -r -a -E '/(usr|bin|sbin|etc|var|opt)\>' $out || true)
    echo -----------
  '';

  passthru.updateScript = deepin.updateScript { inherit name; };

  meta = with stdenv.lib; {
    description = "Starter of deepin desktop environment";
    homepage = https://github.com/linuxdeepin/startdde;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ romildo ];
  };
}
