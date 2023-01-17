##  Sistem Gereksinimleri

**CPU:** 4 CPU

**RAM:** 16 GB

**SSD:** 200 GB


#### Kurulum
```
source <(curl -s https://raw.githubusercontent.com/KriptoKurdu/Node-Kurulumlar/main/NibiruV2.0/nibiru2.sh)
```

#### SNAPSHOT

```
sudo systemctl stop nibid
```


```
cp $HOME/.nibid/data/priv_validator_state.json $HOME/.nibid/priv_validator_state.json.backup
```

```
rm -rf $HOME/.nibid/data 
```

```
curl -L https://snapshots.kjnodes.com/nibiru-testnet/snapshot_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.nibid
```

```
mv $HOME/.nibid/priv_validator_state.json.backup $HOME/.nibid/data/priv_validator_state.json
```


```
nibid start
```





Eski cüzdani eklemek İçin
```
nibid keys add wallet --recover
```
Yeni cüzdan oluşturmak için
```
nibid keys add cuzdanAdi
```

Node durdurmak için
```
sudo systemctl stop nibid
```



#### İlk Defa VALİDATOR Oluşturacaklar için ('cuzdanAdiniz' Kısmını kendinize göre değiştirin)
```
nibid tx staking create-validator \
--amount=100000unibi \
--pubkey=$(nibid tendermint show-validator) \
--moniker=monikerAdi \
--chain-id=nibiru-testnet-2 \
--commission-rate="0.1" \
--commission-max-rate="0.10" \
--commission-max-change-rate="0.01" \
--min-self-delegation="1" \
--fees=10000unibi \
--from=cuzdanAdi \
-y
```

Delege Etmek için
```
nibid tx staking delegate validator_adresi 99500000unibi --from wallet --chain-id nibiru-testnet-2 --fees 5000unibi
```





