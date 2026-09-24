{
  config,
  lib,
  mkTarget,
  osConfig ? null,
  pkgs,
  ...
}:
let
  isSidra = package: (package.pname or null) == "sidra";
in
mkTarget {
  # Check the installed packages in the deferred config below. Reading
  # home.packages while mkTarget defines its options causes infinite recursion.
  autoEnable = true;

  config =
    { colors }:
    let
      systemPackages = if osConfig == null then [ ] else osConfig.environment.systemPackages or [ ];
      sidraInstalled = lib.any isSidra (config.home.packages ++ systemPackages);
      themeFile = pkgs.writeText "sidra-stylix-custom-theme.json" (builtins.toJSON {
        dark = with colors.withHashtag; {
          base = base00;
          mantle = base01;
          crust = base02;
          surface0 = base02;
          surface1 = base03;
          surface2 = base04;
          overlay = base03;
          text = base05;
          subtext1 = base04;
          subtext0 = base03;
          accent = base0D;
          accentHover = base0E;
        };
      });
    in
    lib.mkIf sidraInstalled {
      # Home Manager links this store file into Sidra's user data directory.
      # force = false keeps an existing user-owned custom theme intact.
      xdg.configFile."Sidra/custom-theme.json" = {
        source = themeFile;
        force = false;
      };

    };
}
