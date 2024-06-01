{
  sbcl,
  jsonrpc,
  symlinkJoin,
  writeText,
  makeWrapper,
  micros,
  lem-mailbox,
  lib,
  libffi,
  SDL2,
  SDL2_ttf,
  ncurses,
  SDL2_image,
  openssl,
  fetchFromGitHub,
}:
sbcl.buildASDFSystem rec {
  pname = "lem";
  version = "latest";

  src = fetchFromGitHub {
    owner = "lem-project";
    repo = "lem";
    rev = "f6333ee3908afc96c22987bc76de4773e56da2b6";
    hash = "sha256-VFl51FGUIPOhy2UoudxYCwcr0RyTxPZUe0aevpk+Vtk=";
    fetchSubmodules = true;
  };
  lispLibs =
    [micros lem-mailbox]
    ++ (with sbcl.pkgs; [
      iterate
      closer-mop
      trivia
      cl-charms
      cl-setlocale
      esrap
      parse-number
      cl-package-locks
      alexandria
      trivial-gray-streams
      trivial-types
      cl-ppcre
      inquisitor
      babel
      bordeaux-threads
      yason
      _3bmd
      _3bmd-ext-code-blocks
      log4cl
      split-sequence
      str
      dexador
      lisp-preprocessor
      trivial-ws
      trivial-open-browser
      swank
      async-process
      jsonrpc
      rove
    ]);

  LD_LIBRARY_PATH = "${SDL2}/lib:${libffi}/lib:${SDL2_ttf}/lib:${SDL2_image}/lib:${ncurses}/lib:${lib.makeLibraryPath [openssl]}";

  nativeBuildInputs = [
    openssl
    makeWrapper
  ];

  buildScript = writeText "build-lem.lisp" ''
    (load (concatenate 'string (sb-ext:posix-getenv "asdfFasl") "/asdf.fasl"))
    (asdf:operate :program-op :lem/executable)
  '';
  # patches = [./remove-quicklisp.patch ./remove-build-operation.patch];
  installPhase = ''
    mkdir -p $out/bin
    cp -v lem $out/bin
    wrapProgram $out/bin/lem \
      --prefix LD_LIBRARY_PATH : $LD_LIBRARY_PATH \
  '';

  passthru = {
    withPackages = import ./wrapper.nix {inherit makeWrapper sbcl lib symlinkJoin;};
  };
  # installPhase = ''
  #   mkdir -p $out/bin
  #   cp -v lem $out/bin
  #   wrapProgram $out/bin/lem \
  #     --prefix LD_LIBRARY_PATH : ${LD_LIBRARY_PATH} \
  # '';
  # buildPhase = ''
  #   ${sbcl}/bin/sbcl --noinform --no-sysinit --no-userinit --load scripts/build-sdl2.lisp
  # '';

  # buildScript = writeText "build-lem.lisp" ''
  #   (load (concatenate 'string (sb-ext:posix-getenv "asdfFasl") "/asdf.fasl"))
  #   (asdf:operate :program-op :lem/executable)
  # '';

  # installPhase = ''
  #   mkdir -p $out/bin
  #   cp -v lem $out/bin
  #   wrapProgram $out/bin/lem \
  #     --prefix LD_LIBRARY_PATH : ${LD_LIBRARY_PATH} \
  # '';

  meta = with lib; {
    description = "Common Lisp editor/IDE with high expansibility";
    homepage = "https://github.com/lem-project/lem";
    changelog = "https://github.com/lem-project/lem/blob/${src.rev}/ChangeLog.md";
    license = licenses.mit;
    maintainers = with maintainers; [zen];
    mainProgram = "lem";
    platforms = platforms.all;
  };
}
