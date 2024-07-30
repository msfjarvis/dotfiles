{
  networks.home = {
    name = "Home";
    cidrv4 = "192.168.1.1/24";
  };
  nodes.matara.interfaces.tailscale0.network = "home";
  nodes.ryzenbox.interfaces.tailscale0.network = "home";
}
