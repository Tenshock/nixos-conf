{
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      width = "30%";
      height = "40%";
      prompt = "What is your desire…";
      normal_window = true;
      location = "center";
      gtk-dark = true;
      allow_images = true;
      image_size = 32;
      hide_scroll = true;
      show_all = true;
      insensitive = true;
      allow_markup = true;
      no_actions = true;
      orientation = "vertical";
      halign = "fill";
      content_halign = "fill";
    };
    style = ''
window {
  background-color: #171717;
}

* {
  font-family: "Jetbrains Mono";
  color: #fff;
}

#scroll {
  padding: 0.5rem;
}

#input {
  background-color: #262626;
  outline: none;
  box-shadow: none;
  border: 0;
  border-radius: 0;
  font-size: 1rem;
  padding-left: 1rem;
  padding-right: 1rem;
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
}

#inner-box {
  margin: 0.5rem;
  font-size: 1rem;
}

#img {
  margin: 10px 10px;
}

#entry {
  border-radius: 0.5rem;
}

#entry:selected {
  background-color: #262626;
  outline: none;
}
    '';
  };
}
