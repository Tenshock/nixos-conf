{
  programs.ssh = {
    enableDefaultConfig = false;

    enable = true;
    settings = {
      "github.com" = {
        IdentityAgent = "~/.1password/agent.sock";
      };
    };
  };
}
