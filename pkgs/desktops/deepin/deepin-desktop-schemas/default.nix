{ stdenv, fetchFromGitHub, python, gnome3, deepin-gtk-theme,
  deepin-icon-theme, deepin-sound-theme, deepin-wallpapers, deepin }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "deepin-desktop-schemas";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "1cqxxrj6gs6hccsx776p24k38xrkxv7xp1mp0ya23nvvd7az2rb5";
  };

  nativeBuildInputs = [
    python
    gnome3.glib.dev
  ];

  buildInputs = [
    gnome3.dconf
    deepin-gtk-theme
    deepin-icon-theme
    deepin-sound-theme
    deepin-wallpapers
  ];

  postPatch = ''
    # debugging
    echo -------------; grep --color=always -a -r -E '/(usr|bin|etc|var|lib|opt)' || true
    echo -------------

    # fix default background url
    sed -i -e 's,/usr/share/backgrounds/default_background.jpg,${deepin-wallpapers}/share/backgrounds/deepin/desktop.jpg,' \
      overrides/common/com.deepin.wrap.gnome.desktop.override

    sed -i -e 's,/usr/share/wallpapers/deepin,${deepin-wallpapers}/share/wallpapers/deepin,g' \
      schemas/com.deepin.dde.appearance.gschema.xml

    # still hardcoded paths:
    #   /etc/gnome-settings-daemon/xrandr/monitors.xml                                ? gnome3.gnome-settings-daemon
    #   /usr/share/backgrounds/gnome/adwaita-lock.jpg                                 ? gnome3.gnome-backgrounds
    #   /usr/share/backgrounds/gnome/adwaita-timed.xml                                gnome3.gnome-backgrounds
  '';

  makeFlags = [ "PREFIX=$(out)" ];

  doCheck = true;
  checkTarget = "test";

  postInstall = ''
    glib-compile-schemas --strict $out/share/glib-2.0/schemas
  '';

  postFixup = ''
    # debugging
    echo -------------; grep --color=always -a -r -E '/(usr|bin|etc|var|lib|opt)' $out || true
    echo ------------- 
  '';

  passthru.updateScript = deepin.updateScript { inherit name; };

  meta = with stdenv.lib; {
    description = "GSettings deepin desktop-wide schemas";
    homepage = https://github.com/linuxdeepin/deepin-desktop-schemas;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ romildo ];
  };
}
