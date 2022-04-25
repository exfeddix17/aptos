#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt install curl -y < "/dev/null"
fi
curl -s https://raw.githubusercontent.com/exfeddix17/cryptohodl/main/cryptohodl.sh | bash && sleep 2

sudo apt update && sudo apt install git -y
systemctl stop aptosd
cd $HOME
cp -rf $HOME/.aptos $HOME/aptos_$(date +%s)
rm -rf /opt/aptos/
rm -rf ~/.aptos/waypoint.txt 
rm -rf aptos-core
sudo mkdir -p /opt/aptos/data
git clone https://github.com/aptos-labs/aptos-core.git -b devnet
cd aptos-core
source ~/.cargo/env
cargo build -p aptos-node --release
cargo build -p aptos-operational-tool --release
mv ~/aptos-core/target/release/aptos-node /usr/local/bin
mv ~/aptos-core/target/release/aptos-operational-tool /usr/local/bin
if [ -f ~/.aptos/key/private-key.txt ]; then
    echo ""
else 
    /usr/local/bin/aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file ~/.aptos/key/private-key.txt
fi
wget -O /opt/aptos/data/genesis.blob https://devnet.aptoslabs.com/genesis.blob
wget -q -O ~/.aptos/waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
sed -i.bak -e "s/from_config:.*/from_config: \"$(cat ~/.aptos/waypoint.txt)\"/" $HOME/.aptos/config/public_full_node.yaml

sudo systemctl enable aptosd
sudo systemctl restart aptosd
echo "==================================================="
echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service aptosd status | grep active` =~ "running" ]]; then
  echo -e "Your Aptos node \e[32mupdated and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice aptosd status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your Aptos node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
