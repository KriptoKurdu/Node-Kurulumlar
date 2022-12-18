
## Minimum Sistem Gereksinimleri

**CPU:** 4 CPU

**RAM:** 8 GB

**SSD:** 2000 GB

## Moniker adı belirleme
```
MONIKER="Moniker adiniz"
```

## Güncellemeler
```
sudo apt update
```
```
sudo apt install curl git jq lz4 build-essential -y
```

## Go kurulumu
```
sudo rm -rf /usr/local/go
sudo curl -Ls https://go.dev/dl/go1.19.linux-amd64.tar.gz | sudo tar -C /usr/local -xz
tee -a $HOME/.profile > /dev/null << EOF
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source $HOME/.profile
```

## Github klonlayalım
```
cd $HOME
rm -rf uptick
git clone https://github.com/UptickNetwork/uptick.git
cd uptick
make build
mkdir -p $HOME/.uptickd/cosmovisor/genesis/bin
mv build/uptickd $HOME/.uptickd/cosmovisor/genesis/bin/
rm -rf build
```


## Servis olusturalım
```
curl -Ls https://github.com/cosmos/cosmos-sdk/releases/download/cosmovisor%2Fv1.3.0/cosmovisor-v1.3.0-linux-amd64.tar.gz | tar xz
chmod 755 cosmovisor
sudo mv cosmovisor /usr/bin/cosmovisor

sudo tee /etc/systemd/system/uptickd.service > /dev/null << EOF
[Unit]
Description=uptick-testnet node service
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/cosmovisor run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.uptickd"
Environment="DAEMON_NAME=uptickd"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable uptickd

ln -s $HOME/.uptickd/cosmovisor/genesis $HOME/.uptickd/cosmovisor/current
sudo ln -s $HOME/.uptickd/cosmovisor/current/bin/uptickd /usr/local/bin/uptickd
```


## Node yapılandıralım
```
uptickd config chain-id uptick_7000-2
uptickd config keyring-backend test
uptickd config node tcp://localhost:15657

uptickd init $MONIKER --chain-id uptick_7000-2

curl -Ls https://snapshots.kjnodes.com/uptick-testnet/genesis.json > $HOME/.uptickd/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/uptick-testnet/addrbook.json > $HOME/.uptickd/config/addrbook.json

sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@uptick-testnet.rpc.kjnodes.com:15659\"|" $HOME/.uptickd/config/config.toml

sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0auptick\"|" $HOME/.uptickd/config/app.toml

sed -i -e "s|^pruning *=.*|pruning = \"custom\"|" $HOME/.uptickd/config/app.toml
sed -i -e "s|^pruning-keep-recent *=.*|pruning-keep-recent = \"100\"|" $HOME/.uptickd/config/app.toml
sed -i -e "s|^pruning-keep-every *=.*|pruning-keep-every = \"0\"|" $HOME/.uptickd/config/app.toml
sed -i -e "s|^pruning-interval *=.*|pruning-interval = \"19\"|" $HOME/.uptickd/config/app.toml

sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:15658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:15657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:15060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:15656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":15660\"%" $HOME/.uptickd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:15317\"%; s%^address = \":8080\"%address = \":15080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:15090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:15091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:15545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:15546\"%" $HOME/.uptickd/config/app.toml
```

## Servisi başlatalım
```
sudo systemctl start uptickd && journalctl -u uptickd -f --no-hostname -o cat
```

#### Senkronizasyon Hızlandırma

```
sudo systemctl stop uptickd
```

```
cp $HOME/.uptickd/data/priv_validator_state.json $HOME/.uptickd/priv_validator_state.json.backup
```

```
uptickd tendermint unsafe-reset-all --home $HOME/.uptickd
```


```
STATE_SYNC_RPC=https://uptick-testnet.rpc.kjnodes.com:443
STATE_SYNC_PEER=d5519e378247dfb61dfe90652d1fe3e2b3005a5b@uptick-testnet.rpc.kjnodes.com:15656
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -e "s|^enable *=.*|enable = true|" $HOME/.uptickd/config/config.toml
sed -i.bak -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  $HOME/.uptickd/config/config.toml
sed -i.bak -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  $HOME/.uptickd/config/config.toml
sed -i.bak -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.uptickd/config/config.toml
sed -i.bak -e "s|^persistent_peers *=.*|persistent_peers = \"$STATE_SYNC_PEER\"|" \
  $HOME/.uptickd/config/config.toml
mv $HOME/.uptickd/priv_validator_state.json.backup $HOME/.uptickd/data/priv_validator_state.json
```

```
sudo systemctl start uptickd && journalctl -u uptickd -f --no-hostname -o cat
```




## Durum kontrol
```
uptickd status 2>&1 | jq .SyncInfo
```



## Cüzdan oluşturalım 
```
uptickd keys add wallet
```

## Validator olusturalım

```
uptickd tx staking create-validator \
--amount=1000000auptick \
--pubkey=$(uptickd tendermint show-validator) \
--moniker=<moniker> \
--chain-id=uptick_7000-2 \
--commission-rate=0.05 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=<wallet> \
--gas-adjustment=1.4 \
--gas=auto \
-y
```
