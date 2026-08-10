{
  boot.zswap = {
    enable = true;
    compressor = "zstd";
    zpool = "zsmalloc";
    maxPoolPercent = 25;
    shrinkerEnabled = true;
    acceptThresholdPercent = 90;
  };
}
