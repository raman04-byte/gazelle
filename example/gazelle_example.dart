import 'package:gazelle/gazelle.dart';

class HelloNamePlugin implements GazellePlugin {
  HelloNamePlugin();

  @override
  Future<void> initialize(GazelleContext context) async {
    context.router.get("/hello_name_plugin/:name", (request) async {
      return GazelleRouteHandlerResult(
        statusCode: 200,
        response:
            "Hello, ${request.pathParameters["name"]} ${request.httpRequest.uri.queryParameters["surname"] ?? ""}! (plugin)",
      );
    });
  }
}

class HelloWorldPlugin implements GazellePlugin {
  @override
  Future<void> initialize(GazelleContext context) async {
    await context.register(HelloNamePlugin());
    context.router.get("/hello_world_plugin", (request) async {
      return GazelleRouteHandlerResult(
        statusCode: 200,
        response: "Hello, World! (plugin)",
      );
    });
  }
}

void main() async {
  final app = GazelleApp(address: "localhost", port: 8080);

  app.registerPlugin(HelloWorldPlugin());
  app.get("/hello_world", (request) async {
    return GazelleRouteHandlerResult(
      statusCode: 200,
      response: "Hello, World!",
    );
  });

  await app.start();
}
