{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [ go_1_18 goimports gopls go-outline git ];
}
