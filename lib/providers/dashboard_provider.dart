import 'dart:math';

import 'server_config.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class DashboardProvider {
  void doCall() {}

  Future<Map<String, int>> getData() async {
    final response = await doGet("/api/participantes/dashboard", params: {});

    final decodedData = json.decode(utf8.decode(response.bodyBytes)) as Map;
    final data =
        decodedData.map((key, value) => MapEntry(key as String, value as int));
    return data;
  }

  Future<Map<String, dynamic>> getList(
      {required String status, int length = 0}) async {
    final response =
        await doGet("/api/participantes/get", params: {"estado": status});

    final decodedData = json.decode(utf8.decode(response.bodyBytes)) as Map;
    final dataList = decodedData
            .map((key, value) => MapEntry(key as String, value))["content"]
        as List<dynamic>;
    final data =
        Map.fromEntries(dataList.map((e) => MapEntry("${e['telefono']}", e)));
    return data;
  }

  Future<dynamic> updateFlowStatus({required String status}) async {
    final response = await doGet("/api/participantes/flow-status",
        params: {"status": status});
    final decodedData = json.decode(utf8.decode(response.bodyBytes));
    print(decodedData);
    return decodedData;
  }

  Future<void> doCalls({
    int amount = 20,
  }) async {
    await callNext();
  }

  Future<Map<String, dynamic>> callNext({
    Duration duration = const Duration(seconds: 1),
  }) async {
    await Future.delayed(duration);
    final response = await doGetCustom(
        "nhd59lyhhk.execute-api.us-east-1.amazonaws.com", "/dev");
    final decodedData = json.decode(utf8.decode(response.bodyBytes));
    return decodedData;
  }

  Future<Map<String, dynamic>> callSingle({required String phone}) async {
    final response = await doGetCustom(
        "nhd59lyhhk.execute-api.us-east-1.amazonaws.com", "/dev/call-single",
        params: {"phone": phone});
    final decodedData = json.decode(utf8.decode(response.bodyBytes));
    return decodedData;
  }

  Future<Map<String, dynamic>> callGroup({required List<String> phones}) async {
    final response = await doGetCustom(
        "nhd59lyhhk.execute-api.us-east-1.amazonaws.com", "/dev/call-group",
        params: {"phones": phones});
    final decodedData = json.decode(utf8.decode(response.bodyBytes));
    return decodedData;
  }
}
