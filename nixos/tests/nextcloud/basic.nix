import ../make-test.nix ({ pkgs, ...} : {
  name = "nextcloud-basic";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ globin eqyiel ];
  };

  nodes = {
    nextcloud = { config, pkgs, ... }: {
      services.nextcloud = {
        enable = true;
        nginx.enable = true;
        hostName = "nextcloud";
        config.adminpass = "notproduction";
      };
    };
  };

  testScript = ''
    $nextcloud->start();
    $nextcloud->waitForUnit("nginx");
    $nextcloud->waitForUnit("phpfpm-nextcloud");
    $nextcloud->succeed("curl -sSf http://nextcloud/login");
  '';
})
