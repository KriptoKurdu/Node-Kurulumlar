## Minimum Sistem Gereksinimleri

**CPU:** 1 CPU

**RAM:** 1 GB

**SSD:** -




#### Minima kullanıcısını oluştur

```
sudo adduser minima
```

#### Kullanıcı'ya yetki verme
```
sudo usermod -aG sudo minima
```

#### Minima kullanıcısına geçiş
```
su - minima
```

#### Docker kurulum
```
sudo curl -fsSL https://get.docker.com/ -o get-docker.sh
```
```
sudo chmod +x ./get-docker.sh && ./get-docker.sh
```
```
sudo usermod -aG docker $USER
```

#### 
```
exit
```
```
su - minima
```

#### Node Başlatma
```
docker run -d -e minima_mdspassword=123 -e minima_server=true -v ~/minimadocker9001:/home/minima/data -p 9001-9004:9001-9004 --restart unless-stopped --name minima9001 minimaglobal/minima:latest
```

#### Docker server başlatıyoruz
```
sudo systemctl enable docker.service
```
```
sudo systemctl enable containerd.service
```

#### Otomatik Güncelleme komutu
```
docker run -d --restart unless-stopped --name watchtower -e WATCHTOWER_CLEANUP=true -e WATCHTOWER_TIMEOUT=60s -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower
```

#### Minima terminaline giriş
```
docker exec -it minima9001 minima
```


#### Hesap Bağlama
```
incentivecash uid:XXXX-XXXX
```

