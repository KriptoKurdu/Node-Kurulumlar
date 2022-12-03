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

PEERS="9288e8ab4f01383ac1864ddcb7f9eccc4c2e8810@83.171.248.175:39656,7bbe4afc59fbfff5e6c3189c8ef73a1c6ac3f067@80.82.215.23:26656,9007f52d9f46c581bf4a0fc6f4a108699caa4676@135.181.83.112:39656,d4cc19cf98ff84863916445a33a6301e1bf32866@80.82.215.211:26656,6ed3b1b345e99bca60f04de930d6d11792923713@95.216.159.99:39656,a0dd9905a3511c174c504b1ea953c7e5f1dbc9ab@65.108.217.146:39656,3b8e8283c3778af3c0e29e406f4aee5eb608e64d@62.171.172.51:26656,1b786fbb3a0db6f2ec99fdd2424d4aacddc10ed4@77.75.230.201:26656,66363f55c128ce60bb4c5ebfbc070ec464bcd532@80.82.215.220:26656,fa4c53154dcc202619aa4b5cb156570f45896f45@5.161.56.143:26656"
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
