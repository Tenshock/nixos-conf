let
  systems = let user = "cedric";
  in {
    framework-13 = {
      hostname = "nixos";
      arch = "x86_64-linux";
      inherit user;
    };
    macbook-seekube = {
      hostname = "mbp";
      arch = "aarch64-darwin";
      inherit user;
    };
  };

  formattedSystems =
    builtins.mapAttrs (name: value: value // { dir = name; }) systems;
in formattedSystems

