{
  programs.ssh = {
    enableDefaultConfig = false;

    enable = true;
    matchBlocks = {
      "*" = {
        identityAgent = [
          ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
        ];
      };

      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
      };

      "gitlab.com" = {
        hostname = "altssh.gitlab.com";
        port = 443;
      };
    };
  };
}
