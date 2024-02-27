part of 'mqtt_bloc.dart';

abstract class MqttState extends Equatable {
  const MqttState();
}

class MqttInitial extends MqttState {
  @override
  List<dynamic> get props => [];
}
class MqttReceiveLoaded extends MqttState {
  final List<dynamic> messageList;

  const MqttReceiveLoaded({required this.messageList});

  @override
  List<dynamic> get props => [messageList];
}
