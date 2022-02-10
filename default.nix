let
  pkgs = import <nixpkgs> { };

  # Erlang
  # erlang_custom = pkgs.lib.overrideDerivation pkgs.erlangR23 (oldAttrs: rec {
  #   wxGTK = null;
  #   name = "erlang-" + version;
  #   version = erlang_version;
  #   KERL_BUILD_DOCS = "yes";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "erlang";
  #     repo = "otp";
  #     rev = "OTP-${version}";
  #     sha256 = "0y3bn4pshk3dqvxb0pnb679x44a5mz27r9l7cscxafa98ifsgfsn";
  #   };
  # });
  beamPkg = pkgs.beam.packagesWith pkgs.erlangR23;

  # # Elixir
  # elixir_custom = beamPkg.elixir_1_12;
  # elixir-ls_custom = beamPkg.elixir_ls.override {
  #   elixir = elixir_custom;
  #   mixRelease = beamPkg.mixRelease.override { elixir = elixir_custom; };
  # };

  # Rebar
  rebar_custom = beamPkg.rebar;
  rebar3_custom = beamPkg.rebar3;

  # # Node
  # nodejs_custom = pkgs.nodejs-14_x;
  # yarn_custom = pkgs.yarn.override { nodejs = nodejs_custom; };

in with pkgs; {
  eccEnv = stdenv.mkDerivation {
    name = "env";
    nativeBuildInputs = [
      erlangR23
      elixir_1_12
      azure-cli
      ansible_2_9
      vagrant
      inotify-tools
      terraform
      libxml2
      zip
    ];
    src = null;
    shellHook = ''
      unset ERL_LIBS
      export MIX_REBAR=${rebar_custom}/bin/rebar
      export MIX_REBAR3=${rebar3_custom}/bin/rebar3
    '';
  };
}
