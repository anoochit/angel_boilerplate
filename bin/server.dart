import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/src/core/server.dart';
import 'package:angel_hot/angel_hot.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:logging/logging.dart';

Future<void> main() async {
  var hot = HotReloader(createServer, [Directory('bin'), Directory('lib')]);
  var http = await hot.startServer('0.0.0.0', 3000);

  print('${http.address.address}:${http.port}');
}

Future<Angel> createServer() async {
  var app = Angel();

  app.get('/', (req, res) {
    res.contentType = MediaType.parse('text/json');
    res.write('{"message":"ok"}');
  });

  app.get('/api/version', (req, res) {
    res.contentType = MediaType.parse('text/json');
    res.write('{"version":0.1}');
  });

  app.post('/api/upload', (req, res) async {
    await req.parseBody();
    var file = req.uploadedFiles.first;
    if (file == null) {
      throw AngelHttpException.badRequest(message: 'Bad Request');
    } else {
      var directory = Directory.current;
      var someFile = File('${directory.path}/data/${file.filename}');
      await file.data.pipe(someFile.openWrite());
      res.contentType = MediaType.parse('text/json');
      res.write('{"path":"${someFile.path}", "filename" : "${file.filename}"}');
    }
  });

  app.fallback((req, res) => throw AngelHttpException.notFound(message: 'not found'));

  app.logger = Logger('app')
    ..onRecord.listen((event) {
      print(event);
    });

  return app;
}
