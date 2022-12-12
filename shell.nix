{ pkgs ? import <nixpkgs> { } }:
let
  systemPackages = with pkgs; [ gdal proj geos libspatialite ];

  tools = with pkgs; [
    nodejs
    jq
    nodePackages.uglify-js
    nodePackages.clean-css-cli
    devd
  ];

  elmInputs = with pkgs.elmPackages; [
    elm
    elm-test
    elm-live
    elm-xref
    elm-json
    elm-review
    elm-format
    elm-upgrade
    elm-coverage
    elm-language-server
    elm-optimize-level-2
  ];

  pythonInputs = with pkgs.python310Packages; [
    black
    invoke
    watchdog
    ipython
    pandas
    gdal
    django
    pip
  ];

  pythonLibs = with pkgs.python310Packages; [ toolz pyyaml rich typer aiohttp ];

in pkgs.mkShell {
  packages = elmInputs ++ pythonInputs ++ tools;
  systemPackages = systemPackages;
  buildInputs = pythonLibs;
  PORT = 3000;
}
