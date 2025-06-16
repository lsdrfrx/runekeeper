{ pkgs, ... }:

{
  packages = [ pkgs.git ];

  languages.ruby = {
    enable = true;
    bundler.enable = true;
  };
}
