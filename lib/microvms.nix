{
  # Note: To extend values for new microvms, add a new block here
  # providing a unique `vsock` CID, a unique `tap_if` ID (e.g., "vm-a2"),
  # a unique `mac_addr`, and an unused `ipv4` address for the host bridge.
  microvms = {
    stash = {
      vsock = 1234;
      tap_if = "vm-a1";
      mac_addr = "02:00:00:00:00:01";
      ipv4 = "10.100.0.2";
    };
    booklore = {
      vsock = 1235;
      tap_if = "vm-a2";
      mac_addr = "02:00:00:00:00:02";
      ipv4 = "10.100.0.3";
    };
  };
}
