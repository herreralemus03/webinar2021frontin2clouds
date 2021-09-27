import 'package:flutter/material.dart';
import 'package:outbound/pages/home_page.dart';
import 'package:outbound/pages/websocket_page_sample.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

void connectWs() {
  WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse("ws://localhost:8080/register"));
  channel.stream.listen((message) {
    print(message);
  });
  subscribe(channel, "/topic/message");
}

void subscribe(WebSocketChannel channel, topic) {
  channel.sink.add("SUBSCRIBE\n" +
      "id:" +
      "12" +
      "\n" +
      "destination:" +
      topic +
      "\n" +
      "ack:auto\n" +
      "\n" +
      "\x00");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
