let
  systems = let user = "cedric";
  in {
    framework-13 = {
      hostname = "nixos";
      arch = "x86_64-linux";
      user = user;
    };
    macbook-seekube = {
      hostname = "mbp";
      arch = "aarch64-darwin";
      user = "cedric";
    };
  };

  formattedSystems =
    builtins.mapAttrs (name: value: value // { dir = name; }) systems;
in formattedSystems

