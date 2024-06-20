{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "prometheus-qbittorrent-exporter";
  version = "8ac240b269622e5ef50f4f11b6aa994ac382c755";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "esanchezm";
    repo = "prometheus-qbittorrent-exporter";
    rev = version;
    hash = "sha256-tC08ADfuvCuNjfnnuQie7Otpbk3Im6R6osAx+2ShZwU=";
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
