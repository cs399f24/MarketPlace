#!/bin/bash
yum install -y git
git clone https://github.com/cs399f24/MarketPlace.git 
cd MarketPlace
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
cp marketplace.service /etc/systemd/system
systemctl enable marketplace
systemctl start marketplace