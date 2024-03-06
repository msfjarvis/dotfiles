{lib, ...}: {
  stylix.autoEnable = lib.mkDefault false;
  stylix.image = lib.mkDefault ./wall.png;
  stylix.base16Scheme = lib.mkDefault ./dracula.yml;
}
