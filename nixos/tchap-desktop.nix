{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.callPackage ../packages/tchap-desktop { })
  ];
}
