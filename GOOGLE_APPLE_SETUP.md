# Liik Google / Apple hazırlığı

Android applicationId ve iOS bundle ID: `dev.sryya.liik`.
Bu dosya hesaplarda kayıt oluşturulduğu anlamına gelmez.

## Google

1. Liik için Google Cloud projesi ve OAuth consent screen oluştur; test kullanıcılarını ekle.
2. Android OAuth istemcisini `dev.sryya.liik` ile kaydet. Debug, upload ve Play App Signing sertifikaları farklıdır; kullanılacak her sertifikanın SHA-1 değerini konsola ekle. Yerelde `cd android && ./gradlew signingReport` ile mevcut imzaları kontrol et.
3. Aynı projede iOS OAuth istemcisini `dev.sryya.liik` ile oluştur.
4. Web OAuth istemcisi oluştur. Web istemci ID değerini mobil `GOOGLE_WEB_CLIENT_ID` ve backend `GOOGLE_CLIENT_ID` alanlarına aynı şekilde yaz.
5. Web client ID (`GOOGLE_WEB_CLIENT_ID`), iOS client ID ve ters client ID değerlerini `ios/Flutter/Auth.xcconfig` içine yaz. Backend `GOOGLE_IOS_CLIENT_ID` ve `GOOGLE_ANDROID_CLIENT_ID` değerlerini doldur.

Yerel Google ayarları `liik-512407` projesine ait client ID değerlerini içeriyor. `Auth.xcconfig`, `GoogleService-Info.plist`, yerel Dart yapılandırması ve yerel backend Web/iOS client ID değerleri birbiriyle eşleşiyor. Cloud Console kaydı ve üretim sunucusunun etkin yapılandırması ayrıca doğrulanmalıdır. Proje Firebase SDK kullanmıyor; yalnız Google girişi için google-services.json zorunlu değildir.

## Apple

1. Apple Developer içinde explicit App ID `dev.sryya.liik` kaydet, Sign in with Apple özelliğini etkinleştir. Yerelde Runner.entitlements zaten hazır.
2. Xcode Runner Signing & Capabilities bölümünde doğru Team seç; mevcut Team `8YCWG7PRTV` hesapla doğrulanmalıdır. Provisioning profilini yeni App ID için oluştur/güncelle.
3. App Store Connect içinde Liik kaydını aynı bundle ID ile aç; sayısal Apple ID değerini `APPLE_APP_STORE_ID` alanına yaz.
4. Android/web Apple girişi kullanılacaksa Services ID oluştur, web alan adını ve HTTPS dönüş adresini kaydet: `https://YOUR_API_DOMAIN/auth/apple/callback`. Aynı Services ID değerini mobil `APPLE_SERVICE_ID` ve backend `APPLE_CLIENT_ID` alanlarına yaz. Native iOS için backend `APPLE_MOBILE_CLIENT_ID=dev.sryya.liik` hazırdır.
5. Sunucudaki Apple web akışı için Team ID, Key ID, private key ve client secret alanlarını yapılandır. Private key ve client secret mobil uygulamaya eklenmez.

## Yerel ayarlar ve paketleme

`auth-config.example.json` dosyasını `auth-config.local.json` olarak kopyala ve gerçek değerlerle doldur.

```sh
flutter run --dart-define-from-file=auth-config.local.json
flutter build appbundle --release --dart-define-from-file=auth-config.local.json
flutter build ipa --release --dart-define-from-file=auth-config.local.json
```

Android yayın imzası için `android/key.properties.example` dosyasını `android/key.properties` olarak kopyala; mevcut upload anahtarının yolunu ve bilgilerini yaz. Eksik keystore ile release çıktısı imzasızdır ve mağazaya yüklenemez. Debug imzayla yayın yapılmaz.

Backend `.env.example` Google/Apple alanlarını içerir. Gerçek `.env` değerlerini girdikten sonra `php artisan config:clear` çalıştır.

## Yayın öncesi doğrulama

- Gerçek Android ve iPhone üzerinde Google girişi, iptal ve çıkış akışlarını dene.
- Apple girişini gerçek iPhone'da ilk giriş, tekrar giriş ve e-posta gizleme ile dene.
- Üretim API adresini, gizlilik politikası adresini ve mağaza metadatasını doğrula; gizlilik adresi `https://liik.net/privacy` olarak ayarlıdır.
- Google Play için Play App Signing SHA-1 değerini ayrıca kaydet; internal testing ve TestFlight üzerinden girişleri tekrar dene.

Kaynaklar: https://developers.google.com/identity/sign-in/ios/start-integrating ve https://developer.apple.com/help/account/capabilities/about-sign-in-with-apple

## Xcode Organizer ile Archive

`ios/Runner.xcworkspace` açılır. `ios/Flutter/Auth.xcconfig` içinde
`GOOGLE_IOS_CLIENT_ID`, `GOOGLE_IOS_REVERSED_CLIENT_ID` ve
`GOOGLE_WEB_CLIENT_ID` doldurulur. Web ID backend `GOOGLE_CLIENT_ID`
ile aynı olmalıdır. Android için Web ID `auth-config.local.json` üzerinden verilir.
Google client secret mobil uygulamaya konulmaz.

## 23 Ekim 2026 iOS kontrolü

- Debug, Release ve Profile bundle ID: `dev.sryya.liik`; üçünde de `Runner/Runner.entitlements` bağlı ve Apple giriş yetkisi mevcut.
- Xcode build ayarlarında kalan üç `Bagla app` görüntü adı `Liik` olarak düzeltildi.
- Yerel backend Apple mobil audience değeri `dev.sryya.liik` ile eşleşiyor. Native iOS akışı Services ID kullanmıyor; yerel `APPLE_SERVICE_ID` boş olması bu akışı engellemez.
- Yerel `APPLE_APP_STORE_ID` boş. Mağaza değerlendirme bağlantısı için App Store Connect sayısal ID değeri girilmeli.
- `lib/services/apple_subscription_catalog.dart` hâlâ sekiz `app.bagla.*` abonelik ürününü sorguluyor. Liik App Store Connect ürün kayıtlarıyla karşılaştırılmadan ürün kimlikleri değiştirilmedi; bu, girişten bağımsız bir satın alma kontrolüdür.
- `lib/pages/themes.dart` ve `lib/pages/ai_profile_page.dart` içindeki `bagla`, mevcut backend tema anahtarını kullanıcıya yerelleştirilmiş Classic adıyla gösteriyor; API uyumluluğu için korundu.
- `ios_old/` eski Bagla yapılandırmasını içeriyor; aktif iOS workspace bu dizini kullanmıyor. macOS, Windows, Linux ve web iskeletlerinde de eski uygulama adları var; iOS yayın yapılandırmasına dahil değiller.
- Hesap tarafında Apple Team/App ID capability/provisioning ve Google consent screen durumu doğrulanmalı. Gerçek cihazda ilk giriş, tekrar giriş, iptal ve Apple e-posta gizleme; TestFlight üzerinde de aynı akışlar denenmeli. Yerel yapılandırma eşleşmesi uçtan uca giriş kanıtı değildir.

Doğrulama: `flutter test test/login_page_test.dart` ile 8 test geçti; plist, entitlement ve Xcode proje sözdizimi geçerli. Xcode Release build ayarlarında Google değişkenlerinin gerçek değerlere açıldığı, bundle ID, Liik adı ve entitlement yolu doğrulandı. İmzalı IPA derlemesi ve gerçek hesapla giriş bu kontrolde yapılmadı.
