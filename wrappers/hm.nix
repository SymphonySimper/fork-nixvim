self:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    ;
  cfg = config.programs.nixvim;
  evalArgs = {
    extraSpecialArgs = {
      hmConfig = config;
    };
    modules = [
      ./modules/hm.nix
    ];
  };
in
{
  _file = ./hm.nix;

  imports = [
    (import ./_shared.nix {
      inherit self evalArgs;
      filesOpt = [
        "xdg"
        "configFile"
      ];
    })
  ];

  config = mkIf cfg.enable {
    home.packages = [
      cfg.build.package
      cfg.build.printInitPackage
    ] ++ lib.optional cfg.enableMan self.packages.${pkgs.stdenv.hostPlatform.system}.man-docs;

    home.sessionVariables = mkIf cfg.defaultEditor { EDITOR = "nvim"; };

    programs = mkIf cfg.vimdiffAlias {
      bash.shellAliases.vimdiff = "nvim -d";
      fish.shellAliases.vimdiff = "nvim -d";
      zsh.shellAliases.vimdiff = "nvim -d";
    };
  };
}
