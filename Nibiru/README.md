
## Node Kurulumu



#### İlk kurulum

```http
source <(curl -s https://raw.githubusercontent.com/KriptoKurdu/Node-Kurulumlar/main/Nibiru/Nibiru-V1.sh)
```

#### Cüzdan Oluşturma ( name yerine bir cüzdan ismi yazın)

```javascript
nibid keys add name

nibid keys show name -a 
```



#### Validator

```javascript
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

```javascript
nibid tx staking delegate validator_adresi 10000000unibi --from wallet --chain-id nibiru-testnet-1 --fees 5000unibi

```
#### Senkronizasyon kontrolü

```javascript
nibid status 2>&1 | jq .SyncInfo

```

