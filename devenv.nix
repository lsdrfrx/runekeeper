{ pkgs, ... }:

{
  packages = [ pkgs.git pkgs.bundix ];

  languages.ruby = {
    enable = true;
    bundler.enable = true;
  };
}
