import 'dart:io';

import 'package:gazelle/src/gazelle_context.dart';
import 'package:gazelle/src/gazelle_router.dart';

class GazelleApp {
  final String address;
  final int port;

  late final GazelleContext _context;
  late final HttpServer _server;

  GazelleApp({
    required this.address,
    required this.port,
  }) : _context = GazelleContext.create();

  Future<void> registerPlugin(GazellePlugin plugin) =>
      _context.register(plugin);

  void insertRoute(String route, GazelleRouteHandler handler) =>
      _context.router.insertHandler(route, handler);

  Future<void> start() async {
    _server = await HttpServer.bind(address, port);

    _server.listen((request) {
      final handler = _context.router.searchHandler(request.uri.path);

      if (handler == null) {
        request.response.statusCode = 404;
        request.response.write(_get404ErrorMessage(request.uri.path));
        request.response.close();

        return;
      }

      return handler(_context, request);
    });
  }

  String _get404ErrorMessage(String path) => "Resource [$path] not found.";
}
