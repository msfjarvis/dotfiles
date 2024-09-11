{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication {
  pname = "prometheus-qbittorrent-exporter";
  version = "1.5.1-unstable-2024-08-30";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "esanchezm";
    repo = "prometheus-qbittorrent-exporter";
    rev = "3ade2d1e4324ad9056e7237f1c38f8ac506577f5";
    hash = "sha256-E0v/4rufzEak77o6LDASD40eHkOsEo/OWIWSfJjle0U=";
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
