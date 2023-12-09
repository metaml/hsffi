
{
  description = "generate haskell ffi bindings";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pname = "hsffi";
        version = "0.1.0";
        pkgs = nixpkgs.legacyPackages.${system};
        hkgs = pkgs.haskell.packages.ghc948;
        llvm = pkgs.llvmPackages_latest;

        hsffi = pkgs.runCommand
          pname
          { preferLocalBuild = true; buildInputs = [ pname ]; }
          '''';
        nixConfig.sandbox = "relaxed";
      in {
        packages.${pname} = with import nixpkgs { inherit system; };
          stdenv.mkDerivation {
            __noChroot = true;
            name = "${pname}";
            src = self;
            version = "${version}";

            buildInputs = with pkgs; [
              cabal-install
              cacert
              git
              hkgs.ghc
              hkgs.hlint
              watchexec
              zlib
            ];

            buildPhase = ''
              export HOME=$TMP
              export CABAL_DIR=$TMP
              cabal update --verbose
              mkdir -p $out/bin
            '';
            
            installPhase = ''
              export HOME=$TMP
              export CABAL_DIR=$HOME
              cabal install --install-method=copy --overwrite-policy=always --installdir=$out/bin exe:hsffi
            '';
          };
        packages.default = self.packages.${system}.${pname};
        defaultPackage = self.packages.${system}.default;

        packages.docker = pkgs.dockerTools.buildImage {
          name = "${pname}";
          tag = "latest";
          created = "now";

          copyToRoot = pkgs.buildEnv {
            name = "${pname}";
            paths = with pkgs; [
              cacert
              self.defaultPackage.${system}
            ];
            pathsToLink = [ "/bin/${pname}" ];
          };

          config = {
            WorkingDir = "/";
            Env = [
              "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              "SYSTEM_CERTIFICATE_PATH=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            ];
            EntryPoint = [ "/bin/${pname}" ];
          };
        };

        devShells.default = pkgs.mkShell.override { stdenv = pkgs.clangStdenv; } rec {
          buildInputs = with pkgs; [
            cabal-install
            cacert
            clang
            clang-tools
            coreutils
            findutils
            git
            gnugrep
            gnumake
            gnused
            hkgs.ghc
            hkgs.hlint
            iconv
            libffi
            llvm.libclang
            llvm.libcxx
            llvm.libllvm
            llvm.libstdcxxClang
            sourceHighlight
            watchexec
            zlib
          ];
          # ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
          #   AppKit
          #   ApplicationServices
          #   CoreVideo
          #   fixDarwinDylibNames
          #   OpenGL
          #   Security
          # ]);

          shellHook = ''
            export SHELL=$BASH
            export LANG=en_US.UTF-8
            export PS1="hsffi|$PS1"
            export CC="${llvm.clang}/bin/clang"
            export CXX="${llvm.clang}/bin/clang++"
            export LIBCLANG_PATH="${llvm.libclang.lib}/lib"
          '';

        };

        devShell = self.devShells.${system}.default;
      }
    );
}
