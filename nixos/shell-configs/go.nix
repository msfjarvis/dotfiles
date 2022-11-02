{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [ git go-outline go_1_19 gopls gotools ];
}
