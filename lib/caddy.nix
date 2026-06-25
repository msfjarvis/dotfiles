rec {
  tailnetDomain = "tiger-shark.ts.net";
  mkFail2banLogFormat = site: ''
    output file /var/log/caddy/access-${builtins.replaceStrings [ "/" " " ] [ "_" "_" ] site}.log
    format transform "{common_log}"
    level INFO
  '';
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
