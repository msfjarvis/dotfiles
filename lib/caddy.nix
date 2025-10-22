rec {
  tailnetDomain = "tiger-shark.ts.net";
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
