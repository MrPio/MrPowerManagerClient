import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mr_power_manager_client/Utils/small_utils.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

enum HttpType { get, post, delete }

const web = "https://mrpowermanager.herokuapp.com"; //"http://localhost:5000";

Future<Map<String, dynamic>> requestData(BuildContext context,
    HttpType httpType, String endpoint, Map<String, String> args) async {
  final uri = Uri.parse(web + endpoint).replace(queryParameters: args);
  Response response;
  switch (httpType) {
    case HttpType.get:
      response = await http.get(uri, headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      break;
    case HttpType.post:
      response = await http.post(uri, headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      break;
    case HttpType.delete:
      response = await http.delete(uri, headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      break;
  }
  //print('$uri -->${jsonDecode(response.body)}');
  if (response.statusCode > 299) {
    return <String, dynamic>{};
  }
  return jsonDecode(response.body) as Map<String, dynamic>;
}


class MyStompClient {
  late final StompClient stompClient;
  final String token;
  final void Function(StompFrame) onConnect;
  Map<String,bool> unsubscribe={};
  Map<String,Function(Map)> subscribeStatusCallbacks={};

  MyStompClient(this.token, {required this.onConnect}) {
    stompClient = StompClient(
        config: StompConfig(
      url: 'ws://mrpowermanager.herokuapp.com/chat/websocket',
      onConnect: onConnect,
    ));
  }

  subscribeOnline(StompFrame frame, Function(Map) onCallback) {
    print('subscribeOnline...');
    stompClient.subscribe(
        destination: '/client/${keepOnlyAlphaNum(token)}/online',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            var jsonData = json.decode(frame.body ?? '');
            // print(jsonData);
            onCallback(jsonData);
          }
        });
  }

  subscribeMessage(StompFrame frame, Function(Map) onCallback) {
    print('subscribeMessage...');
    stompClient.subscribe(
        destination: '/both/${keepOnlyAlphaNum(token)}/message',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            var jsonData = json.decode(frame.body ?? '');
            onCallback(jsonData);
          }
        });
  }

  subscribeStatus(String pcName, Function(Map) onCallback) {
    print('subscribeStatus...');

    unsubscribe[pcName]=false;
    stompClient.subscribe(
        destination: '/client/${keepOnlyAlphaNum(token)}/${keepOnlyAlphaNum(pcName)}/status',
        callback: (StompFrame frame) {
          // print('uns:  '+unsubscribe.toString());
          if(unsubscribe[pcName]??false) {
            print ('uns   ...scappo!');
            return;
          }
          if (frame.body != null) {
            var jsonData = json.decode(frame.body ?? '');
            // print(jsonData);
            onCallback(jsonData);
          }
        },);
  }
}
