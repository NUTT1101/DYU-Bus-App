class Stop {
  final String _id;
  final Map<String, String> _stopName;
  final List<double> _position;
  final String _routeID;

  String get getStopId => _id;
  Map<String, String> get getStopName => _stopName;
  List<double> get getPosition => _position;
  String get getRouteID => _routeID;

  Stop({
    required String id,
    required Map<String, String> stopName,
    required List<double> position,
    required String routeID,
  })  : _id = id,
        _stopName = stopName,
        _position = position,
        _routeID = routeID;
}
