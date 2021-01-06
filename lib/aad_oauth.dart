library aad_oauth;

import 'model/config.dart';
import 'package:flutter/material.dart';
import 'helper/auth_storage.dart';
import 'model/token.dart';
import 'request_code.dart';
import 'request_token.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class AadOAuth {
  static Config _config;
  AuthStorage _authStorage;
  Token _token;
  RequestCode _requestCode;
  RequestToken _requestToken;

  AadOAuth(Config config) {
    _config = config;
    _authStorage = AuthStorage(tokenIdentifier: config.tokenIdentifier);
    _requestCode = RequestCode(_config);
    _requestToken = RequestToken(_config);
  }

  void setWebViewScreenSize(Rect screenSize) {
    _config.screenSize = screenSize;
  }

  /// requires the lastSaved token for bypassing IOS not saving on cache issue
  Future<dynamic> login(Token lastSavedToken) async {
    await _removeOldTokenOnFirstLogin();
    // detects if there is a token and will get any that is being passed at login
    if (_token == null) {
      _token = lastSavedToken;
    }
    if (!Token.tokenIsValid(_token)) {
      // WOKAROUND STARTS HERE
      // load token from cache
      var checkToken = await _authStorage.loadTokenToCache();

      var hasConnection;
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          hasConnection = true;
        } else {
          hasConnection = false;
        }
      } on SocketException catch (_) {
        hasConnection = false;
      }
      // returns no connection string that will be catched on front end code
      if (!hasConnection && checkToken == null) {
        return 'no-connection';
      }

      await _performAuthorization();
    }
  }

  Future<String> getAccessToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token.accessToken;
  }

  /// gets the token object so ui can save it (IOS Workaround)
  Future<Token> getTokenObject() async {
    return _token;
  }

  Future<String> getIdToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token.idToken;
  }

  bool tokenIsValid() {
    return Token.tokenIsValid(_token);
  }

  Future<void> logout() async {
    await _authStorage.clear();
    await _requestCode.clearCookies();
    _token = null;
    AadOAuth(_config);
  }

  Future<void> _performAuthorization() async {
    // load token from cache
    _token = await _authStorage.loadTokenToCache();
    //still have refreh token / try to get access token with refresh token
    if (_token != null) {
      await _performRefreshAuthFlow();
    } else {
      try {
        await _performFullAuthFlow();
      } catch (e) {
        rethrow;
      }
    }

    //save token to cache
    await _authStorage.saveTokenToCache(_token);
  }

  Future<void> _performFullAuthFlow() async {
    String code;
    try {
      code = await _requestCode.requestCode();
      if (code == null) {
        throw Exception('Access denied or authentation canceled.');
      }
      _token = await _requestToken.requestToken(code);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _performRefreshAuthFlow() async {
    if (_token.refreshToken != null) {
      try {
        _token = await _requestToken.requestRefreshToken(_token.refreshToken);
      } catch (e) {
        //do nothing (because later we try to do a full oauth code flow request)
      }
    }
  }

  Future<void> _removeOldTokenOnFirstLogin() async {
    var prefs = await SharedPreferences.getInstance();
    final _keyFreshInstall = 'freshInstall';
    if (!prefs.getKeys().contains(_keyFreshInstall)) {
      await logout();
      await prefs.setBool(_keyFreshInstall, false);
    }
  }
}
