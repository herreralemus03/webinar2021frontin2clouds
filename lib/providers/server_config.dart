import 'dart:convert';
import 'package:http/http.dart';

const host = "localhost:8080"; // "webinar2021-aws.herokuapp.com";
//const port = 8080;

Future<Response> doGet(String collection, {Map<String, String>? params}) async {
  try {
    final uri = Uri.http(host, collection, params);
    final response = await get(uri, headers: {
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
    final uri = Uri.http(url, collection, params);
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
    final uri = Uri.http(host, collection, params);
    final response = await post(uri, body: json.encode(body), headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    });
    return response;
  } catch (e) {
    rethrow;
  }
}
