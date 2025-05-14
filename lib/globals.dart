import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

late final FlutterSecureStorage storage;
String baseUrl = 'http://localhost:8080/';
//String baseUrl = 'https://pismice.com:443/';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
