import 'dart:async';
import 'dart:io';

import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/src/core/server.dart';
import 'package:angel_hot/angel_hot.dart';
import 'package:logging/logging.dart';

Future<void> main() async {
  var hot = HotReloader(createServer, [Directory('bin'), Directory('lib')]);

  var http = await hot.startServer('0.0.0.0', 3000);

  print('${http.address.address}:${http.port}');
}

Future<Angel> createServer() async {
  var app = Angel();

  app.get('/', (req, res) => 'ok');

  app.fallback((req, res) => throw AngelHttpException.notFound(message: 'not found'));

  app.logger = Logger('app')
    ..onRecord.listen((event) {
      print(event);
    });

  return app;
}
