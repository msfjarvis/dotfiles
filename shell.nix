{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    bash
    diff-so-fancy
    git
    micro
    nixfmt
    rnix-lsp
    shellcheck
    shfmt
  ];
}
