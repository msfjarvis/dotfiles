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
    _qbittorrent = 9007;
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
    gitea = 9019;
    forgejo = 9020;
    paperless-ngx = 9021;
    ncps = 9022;
    umami = 9023;
    hatsu = 9024;
    exporters = {
      node = 9100;
      systemd = 9101;
      qbittorrent = 9102;
      restic-rest-server = 9103;
      postgres = 9104;
      pocket-id = 9105;
      blackbox = 9106;
    };
    clickhouse = {
      http = 9200;
      tcp = 9201;
      postgresql = 9202;
      interserver_http = 9203;
      mysql = 9204;
    };
    qbittorrent = {
      torrenting = 9300;
      webui = 9301;
    };
    kanidm = {
      server = 9400;
      ldap = 9401;
    };
  };
}
