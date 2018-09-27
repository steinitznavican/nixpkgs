import ../make-test.nix ({ pkgs, ...} : {
  name = "nextcloud-with-mysql-and-memcached";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ eqyiel ];
  };

  nodes = {
    client = { config, pkgs, ... }: {
      services.davfs2.enable = true;

      environment.etc."davfs2/secrets" = {
        mode = "600";
        text = ''
          http://nextcloud/remote.php/dav/files/root root hunter2
        '';
      };
    };

    nextcloud = { config, pkgs, ... }: {
      networking.firewall.allowedTCPPorts = [ 80 ];

      services.nextcloud = {
        enable = true;
        hostName = "nextcloud";
        nginx.enable = true;
        https = true;
        caching = {
          apcu = true;
          redis = false;
          memcached = true;
        };
        config = {
          dbtype = "mysql";
          dbname = "nextcloud";
          dbuser = "nextcloud";
          dbhost = "127.0.0.1";
          dbport = 3306;
          dbpass = "hunter2";
          adminpass = "hunter2";
        };
      };

      services.mysql = {
        enable = true;
        bind = "127.0.0.1";
        package = pkgs.mariadb;
        initialScript = pkgs.writeText "mysql-init" ''
          CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'hunter2';
          CREATE DATABASE IF NOT EXISTS nextcloud;
          GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER,
            CREATE TEMPORARY TABLES ON nextcloud.* TO 'nextcloud'@'localhost'
            IDENTIFIED BY 'hunter2';
          FLUSH privileges;
        '';
      };

      systemd.services."nextcloud-setup"= {
        requires = ["mysql.service"];
        after = ["mysql.service"];
      };

      services.memcached.enable = true;

      services.davfs2.enable = true;

      environment.etc."davfs2/secrets" = {
        mode = "600";
        text = ''
          http://nextcloud/remote.php/dav/files/root root hunter2
        '';
      };
    };
  };

  testScript = let
    configureMemcached = pkgs.writeScript "configure-memcached" ''
      #!${pkgs.stdenv.shell}
      nextcloud-occ config:system:set memcached_servers 0 0 --value 127.0.0.1 --type string
      nextcloud-occ config:system:set memcached_servers 0 1 --value 11211 --type integer
      nextcloud-occ config:system:set memcache.local --value '\OC\Memcache\APCu' --type string
      nextcloud-occ config:system:set memcache.distributed --value '\OC\Memcache\Memcached' --type string
    '';
    diffSharedFile = pkgs.writeScript "diff-shared-file" ''
      #!${pkgs.stdenv.shell}
      echo "waiting for FUSE..."
      sleep 10

      diff <(echo 'hi') /mnt/shared-file
    '';
  in ''
    startAll();
    $nextcloud->waitForUnit("multi-user.target");
    $nextcloud->succeed("${configureMemcached}");
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
