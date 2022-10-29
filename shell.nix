{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    bash
    delta
    git
    micro
    nixfmt
    rnix-lsp
    shellcheck
    shfmt
  ];
}
