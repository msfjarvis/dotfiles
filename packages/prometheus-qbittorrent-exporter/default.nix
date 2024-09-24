{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication {
  pname = "prometheus-qbittorrent-exporter";
  version = "develop1-unstable-2024-09-23";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "esanchezm";
    repo = "prometheus-qbittorrent-exporter";
    rev = "7e0e09513c5f5705b997aff168354613835d5ba0";
    hash = "sha256-LKh4hBFzN9YRFCEUkzit95ix6AmaKG16AxCwNWWDpNo=";
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
