import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'mqtt_event.dart';

part 'mqtt_state.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  MqttBloc() : super(MqttInitial()) {
    on<MqttReceiveEvent>(_onMqttReceiveEvent);
  }

  _onMqttReceiveEvent(MqttReceiveEvent event, Emitter<MqttState> state) {
    emit(MqttInitial());
    emit(MqttReceiveLoaded(messageList: event.messageList));
  }
}
