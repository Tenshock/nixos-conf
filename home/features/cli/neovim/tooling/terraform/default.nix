{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    terraform-ls
    tflint
  ];

  xdg.configFile."nvim/lua/tooling-extras/terraform.lua".source = ./extras.lua;
}
