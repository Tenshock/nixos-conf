{
  services.hyprsunset = {
    enable = true;

    settings = {
      profile = [
        {
          time = "06:30";
          temperature = 4500;
        }
        {
          time = "07:00";
          temperature = 5000;
        }
        {
          time = "07:30";
          temperature = 6000;
        }
        {
          time = "08:00";
          identity = true;
        }
        {
          time = "19:30";
          temperature = 5500;
        }
        {
          time = "20:30";
          temperature = 5000;
        }
        {
          time = "21:30";
          temperature = 4500;
        }
        {
          time = "22:30";
          temperature = 4000;
        }
      ];
    };
  };
}
