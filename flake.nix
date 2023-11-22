{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {self, nixpkgs, flake-utils}: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
  {
    packages.ya-music = pkgs.stdenv.mkDerivation
    {
      name = "yandex-download-music";
      version = "v1.5";
      src = pkgs.fetchFromGitHub {
        owner = "kaimi-io";
        repo = "yandex-music-download";
        rev = "29d73bc0a02bf5d95ba89a011d54d70f85012ab8";
        sha256 = "sha256-jUZ0q4jjITqvfJtOYEEA5qlLidXihdXxjdnGPCV5n2g=";
      };

      nativeBuildInputs = [
        pkgs.makeWrapper
      ];

      buildInputs = [
        pkgs.perl
        (pkgs.buildEnv {
          name = "rt-perl-deps";
          paths = with pkgs.perlPackages; (requiredPerlModules [
              FileUtil
              MP3Tag
              GetoptLongDescriptive LWPUserAgent
              LWPProtocolHttps
              HTTPCookies
              MozillaCA
          ]);
        })
      ];

      installPhase = ''
        mkdir -p $out/bin
        cat src/ya.pl | perl -p -e "s/basename\(__FILE__\)/'ya-music'/g" > $out/bin/ya-music
        chmod +x $out/bin/ya-music
      '';

      postFixup = ''
        wrapProgram $out/bin/ya-music \
          --prefix PERL5LIB : $PERL5LIB
      '';
    };
  });

}
