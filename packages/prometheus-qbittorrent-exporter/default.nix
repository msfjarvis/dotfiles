{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication {
  pname = "prometheus-qbittorrent-exporter";
  version = "1.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "esanchezm";
    repo = "prometheus-qbittorrent-exporter";
    rev = "2b64a91f8d3c3a3b9b80c0e620460b333aa2f84c";
    hash = "sha256-tPt/iS3TroHga6zGdWI4VL9HrZ2s0BSGvV+Wam4cwZo=";
  };

  nativeBuildInputs = [ python3.pkgs.pdm-backend ];

  propagatedBuildInputs = with python3.pkgs; [
    prometheus-client
    python-json-logger
    qbittorrent-api
  ];

  pythonImportsCheck = [ "qbittorrent_exporter" ];

  meta = with lib; {
    description = "A prometheus exporter for qbittorrent written in Python. Simple. Works. Docker image";
    homepage = "https://github.com/esanchezm/prometheus-qbittorrent-exporter";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "qbittorrent-exporter";
  };
}
