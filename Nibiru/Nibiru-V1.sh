echo "██╗  ██╗██████╗ ██╗██████╗ ████████╗ ██████╗     ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗   ██╗";
echo "██║ ██╔╝██╔══██╗██║██╔══██╗╚══██╔══╝██╔═══██╗    ██║ ██╔╝██║   ██║██╔══██╗██╔══██╗██║   ██║";
echo "█████╔╝ ██████╔╝██║██████╔╝   ██║   ██║   ██║    █████╔╝ ██║   ██║██████╔╝██║  ██║██║   ██║";
echo "██╔═██╗ ██╔══██╗██║██╔═══╝    ██║   ██║   ██║    ██╔═██╗ ██║   ██║██╔══██╗██║  ██║██║   ██║";
echo "██║  ██╗██║  ██║██║██║        ██║   ╚██████╔╝    ██║  ██╗╚██████╔╝██║  ██║██████╔╝╚██████╔╝";
echo "╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝    ╚═════╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝  ╚═════╝ ";
echo "                                                                                           ";



sleep 1


# Güncellemeler 
sudo apt update && sudo apt upgrade -y
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# Go setup 

if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi



# MONİKER AD BELİRLEME
read -p "Moniker Adinizi Giriniz : " NODENAME
echo 'export NODENAME='\"${NODENAME}\" >> $HOME/.bash_profile

# REPO YÜKLE

cd $HOME
git clone https://github.com/NibiruChain/nibiru.git
cd nibiru
git checkout v0.15.0
make install


#NODE ÇALIŞTIRMA

nibid config keyring-backend test
nibid config chain-id nibiru-testnet-1
nibid init $NODENAME --chain-id nibiru-testnet-1
nibid config node tcp://localhost:26657




# Genesis yükleme

curl -s https://rpc.testnet-1.nibiru.fi/genesis | jq -r .result.genesis > genesis.json
cp genesis.json $HOME/.nibid/config/genesis.json




# Pers ayarlama

PEERS="659030eeffba5cf38c7d5f66bd46447d2048d443@62.171.171.178:26656,3997242f9646ca642932852b7577ddb9976e0396@5.199.130.53:26656,213d1398817da527b4c3c05f4fe64302382d6733@146.190.99.66:39656,001f41373472f1a04512e75185d2de68a1f390bd@65.108.105.37:28656,01c942713a9b910c4990210459c9360c7e8307bf@161.97.105.134:26656,920a63eac8ddc9ad63b5d5bdb1ff55f0f3dec913@65.21.242.148:26656,4372060d7b7268818944a3697fbad1897152ce0d@5.161.99.245:36656,d458fc63d2c49888af3b91e5d13279dc3c96fa92@185.245.183.232:46656,070d8f6373f57092d53b9a5e0062228074469498@65.109.8.96:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.nibid/config/config.toml

sed -i 's/minimum-gas-prices =.*/minimum-gas-prices = "0.025unibi"/g' $HOME/.nibid/config/app.toml

#Blok süresi ayarlama
CONFIG_TOML="$HOME/.nibid/config/config.toml"
 sed -i 's/timeout_propose =.*/timeout_propose = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_propose_delta =.*/timeout_propose_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_prevote =.*/timeout_prevote = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_prevote_delta =.*/timeout_prevote_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_precommit =.*/timeout_precommit = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_precommit_delta =.*/timeout_precommit_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_commit =.*/timeout_commit = "1s"/g' $CONFIG_TOML
 sed -i 's/skip_timeout_commit =.*/skip_timeout_commit = false/g' $CONFIG_TOML

 
 
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.nibid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.nibid/config/app.toml



nibid tendermint unsafe-reset-all --home $HOME/.nibid



sudo tee /etc/systemd/system/nibid.service > /dev/null <<EOF
[Unit]
Description=nibid
After=network-online.target

[Service]
User=$USER
ExecStart=$(which nibid) start --home $HOME/.nibid
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF



# Node başlat

sudo systemctl daemon-reload
sudo systemctl enable nibid
sudo systemctl restart nibid && sudo journalctl -u nibid -f -o cat
