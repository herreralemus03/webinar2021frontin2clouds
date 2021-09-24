import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketPage extends StatefulWidget {
  const WebSocketPage({Key? key}) : super(key: key);

  @override
  State<WebSocketPage> createState() => _WebSocketPageState();
}

class _WebSocketPageState extends State<WebSocketPage> {
  late WebSocketChannel webSocketChannel;
  @override
  void initState() {
    super.initState();
    webSocketChannel = WebSocketChannel.connect(Uri.parse(
        "wss://1kwq7y5uhj.execute-api.us-east-1.amazonaws.com/development"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder(
          stream: webSocketChannel.stream,
          builder: (context, snapshot) {
            return Text("${snapshot.data}");
          },
        ),
      ),
    );
  }
}
