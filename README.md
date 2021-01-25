# Additional Changes to the plugin

## No Connection handler
This code has a workaround for when the user does not have an internet connection, it will return 'no-connection'

```dart
 var login = await oAuth.login(lastSavedToken); // Type is Token
  if (login == 'no-connection') return null;
```

## In case you want inner links on the login page to open on a new page
On the link you want this to happen just add this param: `openNewPage=true`

it will detect that page and open a browser page instead of opening the webview.



# Azure Active Directory OAuth

[![pub package](https://img.shields.io/pub/v/aad_oauth.svg)](https://pub.dartlang.org/packages/aad_oauth)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![pub points](https://badges.bar/aad_oauth/pub%20points)](https://pub.dev/packages/aad_oauth/score) 
[![Join the chat at https://gitter.im/Earlybyte/aad_oauth](https://badges.gitter.im/Earlybyte/aad_oauth.svg)](https://gitter.im/Earlybyte/aad_oauth?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A Flutter OAuth package for performing user authentication against Azure Active Directory OAuth2 v2.0 endpoint. Forked from [hitherejoe.FlutterOAuth](https://github.com/hitherejoe/FlutterOAuth).

Supported Flows:

- [Authorization code flow (including refresh token flow)](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow)
- [Authorization code flow B2C](https://docs.microsoft.com/en-us/azure/active-directory-b2c/authorization-code-flow)

## Usage

For using this library you have to create an azure app at the [Azure App registration portal](https://apps.dev.microsoft.com/). Use native app as platform type (with callback URL: https://login.live.com/oauth20_desktop.srf).

Afterwards you have to initialize the library as follow:

```dart
  static final Config config = new Config(
    tenant: "YOUR_TENANT_ID",
    clientId: "YOUR_CLIENT_ID",
    scope: "openid profile offline_access",
    redirectUri: "your redirect url available in azure portal"
  );

final AadOAuth oauth = new AadOAuth(config);
```

This allows you to pass in an tenant ID, client ID, scope and redirect url.

Then once you have an OAuth instance, you can call `login()` and afterwards `getAccessToken()` to retrieve an access token:

```dart
await oauth.login();
String accessToken = await oauth.getAccessToken();
```

You can also call `getAccessToken()` directly. It will automatically login and retrieve an access token.

Tokens are stored in Keychain for iOS or Keystore for Android. To destroy the tokens you can call `logout()`:

```dart
await oauth.logout();
```

## B2C Usage

Setup your B2C directory - [Azure AD B2C Setup](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-tenant/).
<br></br>Register an App on the previously created B2C directory - [Azure AD B2C App Register](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-register-applications?tabs=applications).
<br></br>Use native app as plattform type (with callback URL: https://login.live.com/oauth20_desktop.srf).
<br></br>Create your user flows - [Azure AD B2C User Flows](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows)

Add your Azure tenant ID, tenantName, client ID (ID of App), client Secret (Secret of App) and redirectUrl in the main.dart source-code:

```dart
  static final Config configB2Ca = new Config(
      tenant: "YOUR_TENANT_NAME",
      clientId: "YOUR_CLIENT_ID",
      scope: "YOUR_CLIENT_ID offline_access",
      redirectUri: "https://login.live.com/oauth20_desktop.srf",
      clientSecret: "YOUR_CLIENT_SECRET",
      isB2C: true,
      policy: "YOUR_USER_FLOW___USER_FLOW_A",
      tokenIdentifier: "UNIQUE IDENTIFIER A");
```

Afterwards you can login and get an access token for accessing other resources. You can also use multiple configs at the same time.

## Installation

Add the following to your pubspec.yaml dependencies:

```yaml
dependencies:
  aad_oauth: "^0.2.0"
```

## Contribution

Contributions can be submitted as pull requests and are highly welcomed. Changes will be bundled together into a release. You can find the next release date and past releases in the [CHANGELOG file](CHANGELOG.md).
