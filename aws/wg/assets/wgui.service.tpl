[Unit]
Description=wireguard-ui service
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
Environment=WGUI_PASSWORD=${wgui_password}
ExecStart=/usr/local/bin/wireguard-ui

[Install]
WantedBy=multi-user.target