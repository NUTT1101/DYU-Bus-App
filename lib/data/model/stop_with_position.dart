import 'package:busapp/data/model/stop.dart';

class StopWithPosition extends Stop {
  final List<double> _position;

  List<double> get getPosition => _position;

  StopWithPosition({
    required String id,
    required Map<String, String> stopName,
    required String routeID,
    required List<double> position,
  })  : _position = position,
        super(
          id: id,
          stopName: stopName,
          routeID: routeID,
        );
}
