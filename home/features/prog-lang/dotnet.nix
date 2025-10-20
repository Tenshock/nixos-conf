{ pkgs, ... }: {
  home.packages = with pkgs; [ dotnet-sdk_9 ];

  programs.neovim = {
    extraPackages = with pkgs; [ dotnet-sdk_9 ];
  };
}
