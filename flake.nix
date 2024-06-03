{
  description = "Lem Editor";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      micros = pkgs.sbcl.buildASDFSystem {
        pname = "micros";
        version = "latest";
        src = pkgs.fetchFromGitHub {
          owner = "lem-project";
          repo = "micros";
          rev = "9fc7f1e5b0dbf1b9218a3f0aca7ed46e90aa86fd";
          hash = "sha256-bLFqFA3VxtS5qDEVVi1aTFYLZ33wsJUf26bwIY46Gtw=";
        };
      };
      jsonrpc = pkgs.sbclPackages.jsonrpc.overrideLispAttrs (oldAttrs: {
        systems = ["jsonrpc" "jsonrpc/transport/stdio" "jsonrpc/transport/tcp"];
        lispLibs = with pkgs.sbclPackages;
          oldAttrs.lispLibs ++ [cl_plus_ssl quri fast-io trivial-utf-8];
      });
      cl-charms =
        pkgs.sbclPackages.cl-charms.overrideLispAttrs
        (oldAttrs: {nativeLibs = [pkgs.ncurses];});
      queues = pkgs.sbclPackages.queues.overrideLispAttrs (oldAttrs: {
        systems = ["queues" "queues.priority-cqueue" "queues.priority-queue" "queues.simple-cqueue" "queues.simple-queue"];
        lispLibs = oldAttrs.lispLibs ++ (with pkgs.sbclPackages; [bordeaux-threads]);
      });
      lem-mailbox = pkgs.sbcl.buildASDFSystem {
        pname = "lem-mailbox";
        version = "latest";
        src = pkgs.fetchFromGitHub {
          owner = "lem-project";
          repo = "lem-mailbox";
          rev = "12d629541da440fadf771b0225a051ae65fa342a";
          hash = "sha256-hb6GSWA7vUuvSSPSmfZ80aBuvSVyg74qveoCPRP2CeI=";
        };
        lispLibs = with pkgs.sbclPackages; [
          bordeaux-threads
          bt-semaphore
          queues
        ];
      };
      lem = pkgs.callPackage ./nix/default.nix {inherit micros lem-mailbox jsonrpc cl-charms;};
    in {
      packages = {
        inherit lem;
        default = lem;
      };
      devShells.default = import ./nix/shell.nix {inherit pkgs;};
    });
}
