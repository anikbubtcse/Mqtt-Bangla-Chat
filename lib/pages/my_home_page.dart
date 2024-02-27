import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../bloc/mqtt_bloc.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final client = MqttServerClient.withPort("broker.hivemq.com", "", 1883);
  final String topic = "demomqtt";
  final TextEditingController messageController = TextEditingController();
  List<dynamic> messageList = [];
  String connectionStatus = '';

  @override
  void initState() {
    mqttConnection();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        centerTitle: true,
        title: const Text(
          'MQTT Protocol - Bloc',
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocConsumer<MqttBloc, MqttState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is MqttReceiveLoaded) {
                    return Expanded(
                      child: ListView.builder(
                          itemCount: state.messageList.length,
                          itemBuilder: (context, index) {
                            return Text(
                              state.messageList[index]["key"],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            );
                          }),
                    );
                  }

                  return Container();
                }),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        )),
                    onChanged: (value) {
                      messageController.text = value;
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                    onPressed: () {
                      sendMessage();
                      messageController.clear();
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.deepPurple,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  void mqttConnection() async {
    setStatus("Connecting to HiveMQ ...............");

    client.setProtocolV31();
    client.logging(on: true);
    client.keepAlivePeriod = 120;
    client.autoReconnect = true;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribe;

    final MqttConnectMessage connectMessage = MqttConnectMessage()
        .withClientIdentifier(DateTime.now().toString())
        .startClean();
    client.connectionMessage = connectMessage;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print("Connected to HiveMQ Successfully................");
    } else {
      await client.connect();
    }

    client.subscribe(topic, MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> msg) {
      final MqttPublishMessage recMessage =
          msg[0].payload as MqttPublishMessage;

      final pt = utf8.decode(recMessage.payload.message);

      Map<String, dynamic> decodedJson = jsonDecode(pt);
      messageList.add(decodedJson);

      context.read<MqttBloc>().add(MqttReceiveEvent(messageList: messageList));
    });
  }

  void onConnected() {
    setState(() {
      connectionStatus = "Connected";
    });
  }

  void onDisconnected() {
    setState(() {
      connectionStatus = "Disconnected";
    });
  }

  void onSubscribe(String topic) {
    setState(() {
      connectionStatus = "Subscribed to : $topic";
    });
  }

  setStatus(String status) {
    setState(() {
      connectionStatus = status;
    });
  }

  void sendMessage() {
    String bengaliString = messageController.text;
    final Map<String, dynamic> jsonObject = {"key": bengaliString};
    final jsonString = jsonEncode(jsonObject);
    final pt = utf8.encode(jsonString);
    final utfString = utf8.decode(pt);
    final String pubTopic = topic;
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(utfString);
    client.subscribe(pubTopic, MqttQos.atLeastOnce);
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);
  }
}
