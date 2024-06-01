{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "prometheus-qbittorrent-exporter";
  version = "1.5.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "esanchezm";
    repo = "prometheus-qbittorrent-exporter";
    rev = version;
    hash = "sha256-URn5vIrp4OI8+nn2vOCpLhRw50i+ZX2KhuihaVHgASs=";
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
