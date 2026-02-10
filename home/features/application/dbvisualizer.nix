{ pkgs, ... }: {
  home.packages = with pkgs; [ dbvisualizer javaPackages.compiler.openjdk21 ];
}
