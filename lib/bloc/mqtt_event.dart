part of 'mqtt_bloc.dart';

abstract class MqttEvent extends Equatable {
  const MqttEvent();
}

class MqttReceiveEvent extends MqttEvent {
  final List<dynamic> messageList;

  const MqttReceiveEvent({required this.messageList});

  @override
  List<dynamic> get props => [messageList];
}
