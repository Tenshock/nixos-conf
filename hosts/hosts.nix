let
  systems = let
  user = "cedric";
in {
    framework-13 = {
      hostname = "nixos";
      arch = "x86_64-linux";
      user = user;
    };
    hw-macbook = {
      hostname = "M25-HQTH7V320V";
      arch = "aarch64-darwin";
      user = "cprezelin";
    };
  };

  formattedSystems = builtins.mapAttrs (
    name: value:
      value // { dir = name; }
  ) systems;
in
formattedSystems

