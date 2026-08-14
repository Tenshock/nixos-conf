{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = with pkgs; [
      terraform-ls
      tflint
    ];

    extras.lang.terraform.enable = true;
  };
}
