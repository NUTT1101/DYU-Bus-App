import 'package:busapp/data/model/stop.dart';

class StopWithTime extends Stop {
  final int _arrivalTime;
  final int _departureTime;

  int get getArrivalTime => _arrivalTime;
  int get getDeparturnnTime => _departureTime;

  StopWithTime({
    required String id,
    required Map<String, String> stopName,
    required List<double> position,
    required String routeID,
    required int arrivalTime,
    required int departureTime,
  })  : _arrivalTime = arrivalTime,
        _departureTime = departureTime,
        super(
          id: id,
          stopName: stopName,
          position: position,
          routeID: routeID,
        );
}
