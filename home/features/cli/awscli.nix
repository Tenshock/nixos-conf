{
  programs.awscli = {
    enable = true;

    settings = {
      "sso-session seekube-dev" = {
        sso_start_url = "https://d-806776fd05.awsapps.com/start";
        sso_region = "eu-west-3";
        sso_registration_scopes = "sso:account:access";
      };

      "profile dev" = {
        region = "eu-west-3";
        output = "json";
        sso_session = "seekube-dev";
        sso_account_id = "451395191100";
        sso_role_name = "AdministratorAccess";
      };

      "default" = {
        region = "eu-west-3";
      };
    };
  };
}
