import ../make-test.nix ({ pkgs, ...} : {
  name = "nextcloud-basic";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ globin eqyiel ];
  };

  nodes = {
    client = { config, pkgs, ... }: {
      services.davfs2.enable = true;

      environment.etc."davfs2/secrets" = {
        mode = "600";
        text = ''
          http://nextcloud/remote.php/dav/files/root root notproduction
        '';
      };
    };

    nextcloud = { config, pkgs, ... }: {
      networking.firewall.allowedTCPPorts = [ 80 ];

      services.nextcloud = {
        enable = true;
        nginx.enable = true;
        hostName = "nextcloud";
        config.adminpass = "notproduction";
      };

      services.davfs2.enable = true;

      environment.etc."davfs2/secrets" = {
        mode = "600";
        text = ''
          http://nextcloud/remote.php/dav/files/root root notproduction
        '';
      };
    };

  };

  testScript = let
    diffSharedFile = pkgs.writeScript "diff-shared-file" ''
      #!${pkgs.stdenv.shell}
      echo "waiting for FUSE..."
      sleep 10

      diff <(echo 'hi') /mnt/shared-file
    '';
  in ''
    startAll();
    $nextcloud->waitForUnit("multi-user.target");
    $nextcloud->succeed("curl -sSf http://nextcloud/login");
    $nextcloud->succeed("mkdir /mnt && mount -t davfs http://nextcloud/remote.php/dav/files/root /mnt");
    $nextcloud->waitForUnit("sys-fs-fuse-connections.mount");
    $nextcloud->succeed("echo 'hi' > /mnt/shared-file");
    $client->waitForUnit("multi-user.target");
    $client->succeed("mkdir /mnt && mount -t davfs http://nextcloud/remote.php/dav/files/root /mnt");
    $client->waitForUnit("sys-fs-fuse-connections.mount");
    $client->succeed("${diffSharedFile}");
  '';
})
