
## MİNİMA CLAİM REHBERİ

### Selam arkadaşlar bu yazımızda minima da cüzdan güvenliğimizi nasıl sağlarız ve claim işlemini nasıl yaparız ondan bahsedicez

İlk olarak cüzdan güvenliğinden bahsetmek istiyorum bunun için sadece seed kelimelerini almamız yetmiyor bunun haricinde yedek alma işlemlerini de yapmamız gerekiyor

NOT : yedek alma ve taşıma işlemlerinde yedekleri kendi bilgisayarımıza taşımamız gerekiyor bunun için Putty yerine dosya transferi yapabileceğimiz bir uygulama kullanmamız gerekiyor (Örneğin: WinSCP)

1. Adım ) Yeni bir minima sunucusu kurmanız gerekiyor bunun için aşağıdaki videodan yararlanabilirsiniz (Not : Kurulumda ki son aşamada hesap bağlama kısmını yapmanıza gerek yok)

ÖNEMLİ : MDS şifrenizi biraz daha karmaşık bir sayı yapın yani "123" değilde "at87k" gibi


2. Adım ) Yeni node'u kurduktan sonra  sunucuya giriş yapalım ve sırasıyla aşağıdaki kodları uygulayarak cüzdan kelimelerimizi alalım.( "phrase" kısmının yanında yazanlar minima hesabınızın 24 kelimesi bunu mutlaka kayıt edelim.) "MİNİMA" yazılı kısım açık ise direk 3. kodu "vault" yazarak kelimelere erişebilirsiniz

```
su - minima
```
```
docker exec -it minima9001 minima
```
```
vault
```


3. Adım ) Şimdi de yedekleri almamız gerekicek bunun içinde aşağıdaki kodu kullanalım . Çıktıdaki file ile başlayan kısımdaki yedek ismini de bir yere yazalım (Örnek : "minima-backup-1678901520559.bak" ) . Yedeği bilgisyara da indirmek için WinSCP ile sunucuya bağlanıp "minimadocker9001" klasörünün içinden indirebiliriz.
```
backup password: 
```


4. Adım  ) Gerekli yedekleri aldıktan sonra nodeun kurulu olduğu sunucuya gidip almış olduğumuz cüzdan ve genel yedeği oraya aktarmamız gerekiyor bunun için node kurulu olduğu sunucuya gidip aşağıdaki kodları sırasıyla uygulayalım.
```
su - minima
```
```
docker exec -it minima9001 minima
```
```
vault
```

Burada cüzdanın mevcut cüzdan kelimelerini göreceksiniz ardından aşağıdaki kodu uygulayarak yeni kurulan cüzdandaki kelimeleri eski cüzdana eklemiş olacağız.

```
vault action:restorekeys phrase:"yeninodedaki24kelime"
```

Cüzdan kelimelerini import ettikten sonra sıra yedeklere geldi WinSCP üzerinden sunucumuzun dosyalarına erişelim ve kendi bilgisayarımıza aldığımız yedek dosyasını "minimadocker9001" klasörünün içine bırakabiliriz. Ardından konsol ekranına geçip aşağıdaki kodu uygulayalım
```
restore file:minima-backup-xxxxxxx.bak password:
```

"minima-backup-xxxxxxx.bak" Yazan yere yeni kurduğumuz sunucunun yedek ismini yazacağız ( Örneğin restore file:minima-backup-1678901520559.bak password: )


Yedekler yüklendikten sonra aşağıdaki kodu yazıp sunuzumuzu restart edelim
```
docker restart minima9001
```

BU AŞAMAYA KADAR YAPTIĞIMIZ İŞLEMLER TAMAMEN CÜZDAN GÜVENLİĞİ İLE ALAKALI 




### MDS Sistemine erişim

Node'un kurulu olduğu sunucunun Public IP adresi ile https://sunucuipsi:9003/ adresinden giriş yapın. Hata alırsanız ilk https://sunucuipsi:9004/ adresinden güvenlik uyarısını kabul edin. daha sonra tekrar https://sunucuipsi:9003/ bu adresten devam edin. Sorun almaya devam ederseniz aşağıdaki linkteki adımları uygulayabilirsiniz.

[MDS BAĞLANMA SORUNU](https://magnificent-almandine-948.notion.site/Minima-d-l-FAQ-828d9de5332a4c70b50027395650d9f8)

1. ADIM - )
 Aşağıadki siteye giderek en üstteki uygulamayı "Get" diyerek indirelim


2. Adım - ) 
MDS ye giriş yapalım ve en altta bulunan "Install a MiniDAPP" kısmında "Choose File" diyerek indirdiğimiz zip dosyasını seçip "install" butonuna bir kere basarak kurulumun tamamlanmasını bekleyelim. Yüklendikten sonra tekrardan menüye geçerek yüklediğimiz uygulamanın üstüne basalım ve yeni bir sayfa açılacak.

Bu kısımda istenilen mail ve şifre node u ilk kurduğumuzda ki giriş yaptığımız yerin bilgileri 



