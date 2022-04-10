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
cp -r $HOME/.aptos $HOME/aptos_$(date +%s)
rm -rf /opt/aptos/
rm -rf ~/.aptos/config/
rm -rf ~/.aptos/waypoint.txt 
rm -rf aptos-core
sudo mkdir -p /opt/aptos/data .aptos/config .aptos/key
git clone https://github.com/aptos-labs/aptos-core.git -b devnet
cd aptos-core
#git checkout origin/devnet &>/dev/null
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
/usr/local/bin/aptos-operational-tool extract-peer-from-file --encoding hex --key-file ~/.aptos/key/private-key.txt --output-file ~/.aptos/config/peer-info.yaml &>/dev/null
cp ~/aptos-core/config/src/config/test_data/public_full_node.yaml ~/.aptos/config
wget -O /opt/aptos/data/genesis.blob https://devnet.aptoslabs.com/genesis.blob
wget -q -O ~/.aptos/waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
WAYPOINT=$(cat ~/.aptos/waypoint.txt)
PRIVKEY=$(cat ~/.aptos/key/private-key.txt)
PEER=$(sed -n 2p ~/.aptos/config/peer-info.yaml | sed 's/.$//')
sed -i.bak -e "s/from_config:.*/from_config: \"$WAYPOINT\"/" $HOME/.aptos/config/public_full_node.yaml
sed -i "s/genesis_file_location: .*/genesis_file_location: \"\/opt\/aptos\/data\/genesis.blob\"/" $HOME/.aptos/config/public_full_node.yaml
sleep 2 
sed -i "s/127.0.0.1/0.0.0.0/" $HOME/.aptos/config/public_full_node.yaml
sed -i '/network_id: "public"$/a\
      identity:\
        type: "from_config"\
        key: "'$PRIVKEY'"\
        peer_id: "'$PEER'"' $HOME/.aptos/config/public_full_node.yaml


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
