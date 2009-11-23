{ stdenv, lndir }:

rec {

  # Run the shell command `buildCommand' to produce a store path named
  # `name'.  The attributes in `env' are added to the environment
  # prior to running the command.
  runCommand = name: env: buildCommand:
    stdenv.mkDerivation ({
      inherit name buildCommand;
    } // env);


  # Create a single file.
  writeTextFile =
    { name # the name of the derivation
    , text
    , executable ? false # run chmod +x ?
    , destination ? ""   # relative path appended to $out eg "/bin/foo"
    }:
    runCommand name {inherit text executable; }
      ''
        n=$out${destination}
        mkdir -p "$(dirname "$n")"
        echo -n "$text" > "$n"
        (test -n "$executable" && chmod +x "$n") || true
      '';

    
  # Shorthands for `writeTextFile'.
  writeText = name: text: writeTextFile {inherit name text;};
  writeScript = name: text: writeTextFile {inherit name text; executable = true;};
  writeScriptBin = name: text: writeTextFile {inherit name text; executable = true; destination = "/bin/${name}";};


  # Create a forest of symlinks to the files in `paths'.
  symlinkJoin = name: paths:
    runCommand name { inherit paths; }
      ''
        mkdir -p $out
        for i in $paths; do
          ${lndir}/bin/lndir $i $out
        done
      '';


  # Make a package that just contains a setup hook with the given contents.
  makeSetupHook = script:
    runCommand "hook" {}
      ''
        ensureDir $out/nix-support
        cp ${script} $out/nix-support/setup-hook
      '';


  # Write the references (i.e. the runtime dependencies in the Nix store) of `path' to a file.
  writeReferencesToFile = path: runCommand "runtime-deps"
    {
      exportReferencesGraph = ["graph" path];
    }
    ''
      touch $out
      while read path; do
        echo $path >> $out
        read dummy
        read nrRefs
        for ((i = 0; i < nrRefs; i++)); do read ref; done
      done < graph
    '';

  # Quickly create a set of symlinks to derivations.
  # entries is a list of attribute sets like { name = "name" ; path = "/nix/store/..."; }
  linkFarm = name: entries: runCommand name {} ("mkdir -p $out; cd $out; \n" +
    (stdenv.lib.concatMapStrings (x: "ln -s '${x.path}' '${x.name}';\n") entries));

}
