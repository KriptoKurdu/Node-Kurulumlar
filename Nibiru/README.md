
## Node Kurulumu




## Minimum Sistem Gereksinimleri

**CPU:** 4 CPU

**RAM:** 8 GB

**SSD:** 200 GB




#### İlk kurulum

```
source <(curl -s https://raw.githubusercontent.com/KriptoKurdu/Node-Kurulumlar/main/Nibiru/Nibiru-V1.sh)
```

#### Cüzdan Oluşturma ( name yerine bir cüzdan ismi yazın)

```
nibid keys add name

```

#### Validator

```bash
nibid tx staking create-validator \
--amount 10000000unibi \
--commission-max-change-rate "0.1" \
--commission-max-rate "0.20" \
--commission-rate "0.1" \
--min-self-delegation "1" \
--pubkey=$(nibid tendermint show-validator) \
--moniker <your_moniker> \
--chain-id nibiru-testnet-1 \
--gas-prices 0.025unibi \
--from <key-name>

```

#### Delegatör olma
```
nibid tx staking delegate validator_adresi 10000000unibi --from wallet --chain-id nibiru-testnet-1 --fees 5000unibi
```

#### Senkronizasyon kontrolü
```
nibid status 2>&1 | jq .SyncInfo
```

#### Cüzdan kontolü ( name yerine bir cüzdan ismi yazın)
```
nibid keys show name -a 
```

