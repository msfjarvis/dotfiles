{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.starship;
  inherit (lib) mkEnableOption;
in
{
  options.profiles.${namespace}.starship = {
    server = mkEnableOption "Customize starship for servers";
  };
  config = {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        format = if cfg.server then "$directory$git_branch$git_state$git_status➜ " else "$all";
        add_newline = false;
        aws.disabled = true;
        azure.disabled = true;
        battery.disabled = true;
        buf.disabled = true;
        bun.disabled = true;
        c.disabled = true;
        character = {
          disabled = false;
          error_symbol = ''

            [➜](bold red)'';
          success_symbol = ''

            [➜](bold green)'';
        };
        cmake.disabled = true;
        cmd_duration.disabled = true;
        cobol.disabled = true;
        conda.disabled = true;
        container.disabled = true;
        crystal.disabled = true;
        daml.disabled = true;
        dart.disabled = true;
        deno.disabled = true;
        direnv.disabled = true;
        docker_context.disabled = true;
        dotnet.disabled = true;
        elixir.disabled = true;
        elm.disabled = true;
        env_var.disabled = true;
        erlang.disabled = true;
        fennel.disabled = true;
        fill.disabled = true;
        fossil_branch.disabled = true;
        fossil_metrics.disabled = true;
        gcloud.disabled = true;
        git_branch = {
          disabled = cfg.server;
          symbol = " ";
        };
        git_commit.disabled = false;
        git_state.disabled = false;
        git_metrics.disabled = false;
        git_status = {
          disabled = false;
          ahead = "";
          behind = "";
          diverged = "";
          typechanged = "[⇢\($count\)](bold green)";
          use_git_executable = true;
        };
        gleam.disabled = true;
        golang.disabled = true;
        guix_shell.disabled = true;
        gradle = {
          disabled = false;
          symbol = " ";
        };
        haskell.disabled = true;
        haxe.disabled = true;
        helm.disabled = true;
        hg_branch.disabled = true;
        hostname.disabled = true;
        java.disabled = false;
        jobs.disabled = true;
        julia.disabled = true;
        kotlin.disabled = true;
        kubernetes.disabled = true;
        line_break.disabled = true;
        localip.disabled = true;
        lua.disabled = true;
        memory_usage.disabled = true;
        meson.disabled = true;
        mojo.disabled = true;
        nats.disabled = true;
        nim.disabled = true;
        nix_shell.disabled = true;
        nodejs.disabled = true;
        ocaml.disabled = true;
        odin.disabled = true;
        opa.disabled = true;
        openstack.disabled = true;
        os.disabled = true;
        package.disabled = false;
        perl.disabled = true;
        php.disabled = true;
        pijul_channel.disabled = true;
        pulumi.disabled = true;
        purescript.disabled = true;
        python.disabled = false;
        quarto.disabled = true;
        rlang.disabled = true;
        raku.disabled = true;
        red.disabled = true;
        ruby.disabled = true;
        rust.disabled = false;
        scala.disabled = true;
        shell.disabled = true;
        shlvl.disabled = true;
        singularity.disabled = true;
        solidity.disabled = true;
        spack.disabled = true;
        status.disabled = true;
        sudo.disabled = true;
        swift.disabled = true;
        terraform.disabled = true;
        time.disabled = true;
        typst.disabled = true;
        username.disabled = false;
        vagrant.disabled = true;
        vlang.disabled = true;
        vcsh.disabled = true;
        zig.disabled = true;
      };
    };
  };
}
