{
  # Each guest has a dedicated /30 bridge subnet, tap, MAC and VSOCK CID.
  microvms = {
    stash = {
      vsock = 1234;
      tap_if = "vm-a1";
      bridge = "vmbr-a1";
      mac_addr = "02:00:00:00:00:01";
      gateway = "10.100.0.1";
      ipv4 = "10.100.0.2";
    };
    chrome-cdp = {
      vsock = 1236;
      tap_if = "vm-a3";
      bridge = "vmbr-a3";
      mac_addr = "02:00:00:00:00:03";
      gateway = "10.100.0.5";
      ipv4 = "10.100.0.6";
    };
    booklore = {
      vsock = 1235;
      tap_if = "vm-a2";
      bridge = "vmbr-a2";
      mac_addr = "02:00:00:00:00:02";
      gateway = "10.100.0.9";
      ipv4 = "10.100.0.10";
    };
  };
}
