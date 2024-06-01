{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    pkg-config
    gcc
    lolcat
    sbcl
    sbclPackages.qlot
    sbclPackages.qlot-cli
  ];
  LD_LIBRARY_PATH = "${pkgs.SDL2}/lib:${pkgs.libffi}/lib:${pkgs.SDL2_ttf}/lib:${pkgs.SDL2_image}/lib:${pkgs.ncurses}/lib:${pkgs.lib.makeLibraryPath [pkgs.openssl]}";
  shellHook = ''
    printf "\e[3m\e[1m%s\em\n" "Initiating Lem env..." | lolcat
  '';
}
