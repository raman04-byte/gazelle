import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_logger/gazelle_logger.dart';

void main() async {
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "hello_gazelle",
        get: (context, request, resonse) async => GazelleResponse(
          statusCode: GazelleHttpStatusCode.success.ok_200,
          body: "Hello, Gazelle!",
        ),
        preRequestHooks: (context) => [
          context.getPlugin<GazelleLoggerPlugin>().logRequestHook,
        ],
        postResponseHooks: (context) => [
          context.getPlugin<GazelleLoggerPlugin>().logResponseHook,
        ],
      )
    ],
    plugins: [
      GazelleLoggerPlugin(),
    ],
  );

  await app.start();
  print("Gazelle listening at ${app.serverAddress}");
}
