{
  ports = {
    kdeconnect_range = {
      from = 1714;
      to = 1764;
    };
    torrent_range = {
      from = 6881;
      to = 6889;
    };
    caddy = 2019;
    prometheus = 9000;
    alertmanager = 9001;
    grafana = 9002;
    atuin = 9003;
    miniflux = 9004;
    copyparty = 9005;
    stash = 9006;
    qbittorrent = 9007;
    atticd = 9008;
    metube = 9009;
    alps = 9010;
    tandoor = 9011;
    restic-rest-server = 9012;
    betula = 9013;
    firefly-importer = 9014;
    actual = 9015;
    glance = 9016;
    vaultwarden = 9017;
    pocket-id = 9018;
    exporters = {
      node = 9100;
      systemd = 9101;
      qbittorrent = 9102;
      restic-rest-server = 9103;
      postgres = 9104;
    };
    clickhouse = {
      http = 9200;
      tcp = 9201;
      postgresql = 9202;
      interserver_http = 9203;
    };
  };
}
