import 'dart:convert';
import 'package:http/http.dart';

const host = "webinar2021-aws.herokuapp.com";
//const port = 8080;

Future<Response> doGet(String collection, {Map<String, String>? params}) async {
  try {
    final uri = Uri.https(host, collection, params);
    final response = await get(uri, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    });
    return response;
  } catch (e) {
    rethrow;
  }
}

Future<Response> doPost(String collection,
    {required Map<String, dynamic> body, Map<String, String>? params}) async {
  try {
    final uri = Uri.https(host, collection, params);
    final response = await post(uri, body: json.encode(body), headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    });
    return response;
  } catch (e) {
    rethrow;
  }
}

Future<Response> doGetCustom(String url, String collection,
    {Map<String, dynamic>? params}) async {
  try {
    final uri = Uri.https(url, collection, params);
    final response = await get(uri, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    });
    return response;
  } catch (e) {
    rethrow;
  }
}
