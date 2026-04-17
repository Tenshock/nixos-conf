user:
{ pkgs, ... }:
{
  users.users.${user} = {
    packages = with pkgs; [
      prismlauncher
    ];
  };

  services.minecraft-server = {
    enable = false;
    eula = true;
    openFirewall = true;
    declarative = true;
    serverProperties = {
      motd = "NixOS Minecraft server!";
    };
    jvmOpts = "-Xms6G -Xmx6G -XX:+UseZGC";
  };
}
