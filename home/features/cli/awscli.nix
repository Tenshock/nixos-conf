{
  programs.awscli = {
    enable = true;

    settings = {
      "default" = {
        region = "eu-west-3";
      };
    };
  };
}
