{
  lib,
  mame,
  mame-tools,
  runCommand,
}:
runCommand "chdman-${mame.version}"
  {
    # The wrapped tools add the main MAME output to XDG_DATA_DIRS. chdman does
    # not use those emulator assets, so install the underlying binary directly.
    disallowedReferences = [
      mame
      mame-tools
    ];

    meta = {
      description = "Manager for MAME compressed hunks of data (CHD) images";
      homepage = "https://docs.mamedev.org/tools/chdman.html";
      license = with lib.licenses; [
        bsd3
        gpl2Plus
      ];
      mainProgram = "chdman";
      platforms = lib.platforms.unix;
    };
  }
  ''
    install -Dm755 ${mame-tools}/bin/.chdman-wrapped "$out/bin/chdman"
  ''
