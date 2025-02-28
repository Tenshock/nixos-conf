let
  systems = let
  user = "cedric";
in {
    laptop-srp = {
      hostname = "FRALW-724TCS3";
      arch = "x86_64-linux";
      user = user;
    };
  };

  formattedSystems = builtins.mapAttrs (
    name: value:
      value // { dir = name; }
  ) systems;
in
formattedSystems

