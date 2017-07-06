#!/usr/bin/env bash

cd ~
curl https://getcaddy.com | bash
mkdir -p ~/caddy;cd caddy
wget -O Caddyfile https://gist.githubusercontent.com/MSF-Jarvis/bb97d3ff962e604f4da80121ac680f93/raw/d0cd263098e240003cefb6c6705f8d9bf2525309/Caddyfile
cd ~
git clone https://github.com/MSF-Jarvis/core c9sdk
cd c9sdk
bash scripts/install-sdk.sh
node server.js -p 8080 -a : -w ~/ & #starting an unsecured instance
cd ../caddy
caddy
