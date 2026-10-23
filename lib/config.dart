const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://liik.net',
);
// App Store ID (in_app_review için)
const appleAppStoreId = String.fromEnvironment('APPLE_APP_STORE_ID');

const standardAppleEulaUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
const privacyPolicyUrl = 'https://liik.net/privacy';

// Web OAuth client used as the ID token audience on Android and iOS.
// iOS can also read this from GIDServerClientID when archiving in Xcode.
const googleWebServerClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

const appleWebClientId = String.fromEnvironment('APPLE_SERVICE_ID');
