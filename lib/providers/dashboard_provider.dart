import 'dart:math';

import 'package:outbound/models/status.dart';

import 'server_config.dart';
import 'dart:convert';

class DashboardProvider {
  void doCall() {}

  Future<Response> getData() async {
    final response = await doGet("/api/participantes/dashboard", params: {});

    final decodedData = json.decode(utf8.decode(response.bodyBytes));
    final stopped = decodedData["stopped"] as bool;
    final data = (decodedData["data"] as Map)
        .map((key, value) => MapEntry(key, Status(title: key, value: value)))
        .values
        .toList();
    final result = Response(stopped: stopped, values: data);
    return result;
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
    await callGroup();
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
    final response = await doGet("/api/participantes/call-single",
        params: {"destination": phone});
    final decodedData = json.decode(utf8.decode(response.bodyBytes));
    print(decodedData);
    return decodedData;
  }

  Future<void> callGroup(
      {int members = 1,
      int membersInterval = 1,
      int groupsInterval = 1,
      String destinationPhoneNumber = "+50322597130",
      String contactFlowId = "f0f45db7-dfa4-48e5-93bc-f3991cdf1d15",
      String instanceId = "0234cea5-721b-4f50-9f95-fb93571368ad"}) async {
    await doGet("/api/participantes/call-groups", params: {
      "members": "$members",
      "membersinterval": "$membersInterval",
      "groupsinterval": "$groupsInterval",
      "contactFlowId": contactFlowId,
      "instanceId": instanceId,
    });
  }
}
