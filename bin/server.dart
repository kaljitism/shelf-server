import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

const _hostName = 'localhost';
const _port = 8080;

void main(List<String> args) async {
  // First approach to create a server

  // final server = await HttpServer.bind(_hostName, _port);
  // final ioServer = io.IOServer(server);
  //
  // ioServer.mount((request) => shelf.Response.ok("hello, world\n"));

  // Second approach to create a server

  // final ioServer = await io.IOServer.bind(_hostName, _port);
  // ioServer.mount(
  //   (request) => shelf.Response.ok("hello, world\n"),
  // );

  // Third Approach to create a server

  final handlerCascade = shelf.Cascade().add((request) {
    if (request.url.path == 'one') {
      return shelf.Response.ok("handler one's body\n");
    }
    return shelf.Response.notFound('not found\n');
  }).add((request) {
    print(request.url.path);
    if (request.url.path == 'two') {
      return shelf.Response.ok("handler two's body\n");
    }
    return shelf.Response.notFound('not found\n');
  }).add((request) {
    if (request.url.path == 'three') {
      return shelf.Response.ok("handler three's body\n");
    }
    return shelf.Response.notFound('not found\n');
  }).add((request) {
    if (request.headers['custom-header'] != null) {
      return shelf.Response.ok(
          "Response Found: Custom Header: ${request.headers['custom-header']}\n");
    }
    return shelf.Response.notFound("not found\n");
  }).handler;

  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(
        (innerHandler) => (request) async {
          final updatedRequest =
              request.change(headers: {'custom-header': 'custom-value'});
          return await innerHandler(updatedRequest);
        },
      )
      .addHandler(handlerCascade);

  final server = await io.serve(
    handler,
    _hostName,
    _port,
  );

  print("Serving at http://${server.address.host}:${server.port}\n");
}
