{ config, options }:
let
  fallback = {
    base00 = "1f1f28";
    base01 = "16161d";
    base02 = "2a2a37";
    base03 = "54546d";
    base04 = "727169";
    base05 = "dcd7ba";
    base06 = "c8c093";
    base07 = "717c7c";
    base08 = "c34043";
    base09 = "ffa066";
    base0A = "e6c384";
    base0B = "98bb6c";
    base0C = "7fb4ca";
    base0D = "7e9cd8";
    base0E = "957fb8";
    base0F = "d27e99";
  };

  hasStylix = options ? stylix;
  color = name: if hasStylix then config.lib.stylix.colors.${name} else fallback.${name};
in
{
  inherit hasStylix color;
  withHashtag = name: "#${color name}";
}
