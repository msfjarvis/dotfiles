rec {
  tailnetDomain = "tiger-shark.ts.net";
  mkReactionLogFormat = site: ''
    output file /var/log/caddy/access-${builtins.replaceStrings [ "/" " " ] [ "_" "_" ] site}.log
    format transform `{request>client_ip} - - [{ts}] "{request>method} {request>uri} {request>proto}" {status} {size}`
    level INFO
  '';
  mkFail2banLogFormat = mkReactionLogFormat;
  mkTailscaleVHost = name: config: {
    "https://${name}.${tailnetDomain}" = {
      extraConfig = ''
        bind tailscale/${name}
        tailscale ${name} {
          tags "tag:services"
        }
        ${config}
      '';
    };
  };
}
