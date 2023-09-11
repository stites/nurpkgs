{ stdenv, requireFile, openjdk8, gnutar, unzip, mxM ? "4000M" }:

let
  srcs-package = "ace_v3.0_linux86";
  srcs-benchmarks = "benchmarks_v1.0";
in
stdenv.mkDerivation rec {
  name = "ace-${version}";
  version = "3.0";
  srcs = [
    (requireFile rec {
      name = "${srcs-package}.tar.gz";
      sha256 = "62ed2985177f2bd4c702c6f7db48a5926c69580a1facea2ca2b943ab9a4a731c";
      message = ''
        Download ACE from: http://reasoning.cs.ucla.edu/ace/download.php
        then run $ nix-store --add-fixed sha256 ~/Downloads/${name}
      '';
    })
    (requireFile rec {
      name = "${srcs-benchmarks}.zip";
      sha256 = "a699767ece03e0bb04065535210bd7f14d39aa842c1387a7ecb52d4967b2bf26";
      message = ''
        Download benchmarks from: http://reasoning.cs.ucla.edu/ace/download.php
        then run $ nix-store --add-fixed sha256 ~/Downloads/${name}
      '';
    })
  ];

  buildInputs = [ gnutar openjdk8 unzip ];

  sourceRoot = srcs-package;
  buildPhase = let
    mkSubstitution = bin: ''substituteInPlace ${bin} \
        --replace java ${openjdk8}/bin/java \
        --replace '`dirname $0`' $out/share \
        --replace Xmx1512m Xmx${mxM}'';
  in ''
    mkdir -p $out/bin
    mkdir -p $out/share
    ${mkSubstitution "compile"}
    ${mkSubstitution "evaluate"}
    ${mkSubstitution "preprocess_noisy"}
    ${mkSubstitution "uai08_pe"}
    ${mkSubstitution "uai08_marginals"}
    ${mkSubstitution "uai08_convert"}
  '';
  installPhase = let
    installBin = bin: "mv $out/share/${bin} $out/bin";
  in ''
    cp -r . $out/share
    ${installBin "compile"}
    ${installBin "evaluate"}
    ${installBin "preprocess_noisy"}
    ${installBin "uai08_pe"}
    ${installBin "uai08_marginals"}
    ${installBin "uai08_convert"}

    cp -r ../${srcs-benchmarks} $out/share/benchmarks
  '';
}
