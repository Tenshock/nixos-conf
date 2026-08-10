let
  homeOutput = (import ./home.nix).output;

  voiceEqualizerChannel = {
    band0 = {
      frequency = 80.0;
      gain = 0.0;
      mode = "RLC (BT)";
      mute = false;
      q = 0.7;
      slope = "x2";
      solo = false;
      type = "Hi-pass";
      width = 4.0;
    };
    band1 = {
      frequency = 220.0;
      gain = -2.0;
      mode = "RLC (MT)";
      mute = false;
      q = 0.7;
      slope = "x1";
      solo = false;
      type = "Bell";
      width = 4.0;
    };
    band2 = {
      frequency = 350.0;
      gain = -2.0;
      mode = "BWC (MT)";
      mute = false;
      q = 1.2;
      slope = "x2";
      solo = false;
      type = "Bell";
      width = 4.0;
    };
    band3 = {
      frequency = 3500.0;
      gain = 2.0;
      mode = "BWC (BT)";
      mute = false;
      q = 0.9;
      slope = "x2";
      solo = false;
      type = "Bell";
      width = 4.0;
    };
    band4 = {
      frequency = 10000.0;
      gain = 2.0;
      mode = "LRX (MT)";
      mute = false;
      q = 0.7;
      slope = "x1";
      solo = false;
      type = "Hi-shelf";
      width = 4.0;
    };
  };
in
{
  output = homeOutput // {
    plugins_order = [ "equalizer#0" ] ++ homeOutput.plugins_order;

    "equalizer#0" = {
      balance = 0.0;
      bypass = false;
      decramp = "Off";
      input-gain = 0.0;
      left = voiceEqualizerChannel;
      mode = "IIR";
      num-bands = 5;
      output-gain = 0.0;
      pitch-left = 0.0;
      pitch-right = 0.0;
      right = voiceEqualizerChannel;
      split-channels = false;
    };
  };
}
