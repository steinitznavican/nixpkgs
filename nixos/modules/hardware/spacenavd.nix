{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.spacenavd;

in

{
  options.hardware.spacenavd = {
    enable = mkEnableOption "spacenavd" // {
      description = ''
        Enables spacenavd, a user-space driver for 6-dof input
        devices, like 3Dconnexion's space-mice. It's compatible with the
        original 3dxsrv proprietary daemon provided by 3Dconnexion, and works
        as a drop-in replacement with any program that was written for the
        3Dconnexion driver, but also provides an improved communication
        mechanism for programs designed specifically to work with spacenavd.'';
    };
  };

  # TODO allow specifying custom config, write to /etc/spnavrc?
  # or upstream config file path?

  config = mkIf cfg.enable {
    systemd.services.spacenavd = {
      description = "3Dconnexion Input Devices Userspace Driver";
      # TODO figure out how/if it connects to X11
      after = [ "display-manager.service" ];

      serviceConfig = {
        Type = "forking";
        PIDFile = "/var/run/spnavd.pid";
        ExecStart = "${pkgs.spacenavd}/bin/spacenavd";
        #  StandardError = "syslog";
      };
    };
  };
}
