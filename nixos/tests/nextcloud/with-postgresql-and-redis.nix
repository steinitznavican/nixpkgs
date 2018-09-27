import ../make-test.nix ({ pkgs, ...} : {
  name = "nextcloud-with-postgresql-and-redis";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ eqyiel ];
  };

  nodes = {
    client = { config, pkgs, ... }: {
      services.davfs2.enable = true;

      environment.etc."davfs2/secrets" = {
        mode = "600";
        text = ''
          http://nextcloud/remote.php/dav/files/custom-admin-username custom-admin-username hunter2
        '';
      };
    };

    nextcloud = { config, pkgs, ... }: {
      networking.firewall.allowedTCPPorts = [ 80 ];

      services.nextcloud = {
        enable = true;
        hostName = "nextcloud";
        nginx.enable = true;
        caching = {
          apcu = false;
          redis = true;
          memcached = false;
        };
        config = {
          dbtype = "pgsql";
          dbname = "nextcloud";
          dbuser = "nextcloud";
          dbhost = "localhost";
          dbpassFile = toString (pkgs.writeText "db-pass-file" ''
            hunter2
          '');
          adminlogin = "custom-admin-username";
          adminpassFile = toString (pkgs.writeText "admin-pass-file" ''
            hunter2
          '');
        };
      };

      systemd.services.nextcloud-chown.after = [
        "postgresql.service"
        "chown-redis-socket.service"
      ];

      services.redis = {
        unixSocket = "/var/run/redis/redis.sock";
        enable = true;
        extraConfig = ''
          unixsocketperm 770
        '';
      };

      systemd.services.redis = {
        preStart = ''
          mkdir -p /var/run/redis
          chown ${config.services.redis.user}:${config.services.nginx.group} /var/run/redis
        '';
        serviceConfig.PermissionsStartOnly = true;
      };

      systemd.services."nextcloud-setup"= {
        requires = ["postgresql.service"];
        after = ["postgresql.service"];
      };

      systemd.services."chown-redis-socket" = {
        enable = true;
        script = ''
          until ${pkgs.redis}/bin/redis-cli ping; do
            echo "waiting for redis..."
            sleep 1
          done
          chown ${config.services.redis.user}:${config.services.nginx.group} /var/run/redis/redis.sock
        '';
        after = [ "redis.service" ];
        requires = [ "redis.service" ];
        wantedBy = [ "redis.service" ];
        serviceConfig = {
          Type = "oneshot";
        };
      };

      services.postgresql = {
        enable = true;
        initialScript = pkgs.writeText "psql-init" ''
          create role nextcloud with login password 'hunter2';
          create database nextcloud with owner nextcloud;
        '';
      };

      services.davfs2.enable = true;

      environment.etc."davfs2/secrets" = {
        mode = "600";
        text = ''
          http://nextcloud/remote.php/dav/files/custom-admin-username custom-admin-username hunter2
        '';
      };
    };
  };

  testScript = let
    configureRedis = pkgs.writeScript "configure-redis" ''
      #!${pkgs.stdenv.shell}
      nextcloud-occ config:system:set redis 'host' --value '/var/run/redis/redis.sock' --type string
      nextcloud-occ config:system:set redis 'port' --value 0 --type integer
      nextcloud-occ config:system:set memcache.local --value '\OC\Memcache\Redis' --type string
      nextcloud-occ config:system:set memcache.locking --value '\OC\Memcache\Redis' --type string
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
    $nextcloud->succeed("${configureRedis}");
    $nextcloud->succeed("curl -sSf http://nextcloud/login");
    $nextcloud->succeed("mkdir /mnt && mount -t davfs http://nextcloud/remote.php/dav/files/custom-admin-username /mnt");
    $nextcloud->waitForUnit("sys-fs-fuse-connections.mount");
    $nextcloud->succeed("echo 'hi' > /mnt/shared-file");
    $client->waitForUnit("multi-user.target");
    $client->succeed("mkdir /mnt && mount -t davfs http://nextcloud/remote.php/dav/files/custom-admin-username /mnt");
    $client->waitForUnit("sys-fs-fuse-connections.mount");
    $client->succeed("${diffSharedFile}");
  '';
})
