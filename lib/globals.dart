import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

late final FlutterSecureStorage storage;
//String baseUrl = 'http://91.99.14.212:8080/';
//String baseUrl = 'http://pismice.com:8080/';
String baseUrl = 'https://pismice.com:443/';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
