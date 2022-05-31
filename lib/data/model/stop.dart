class Stop {
  final String _id;
  final Map<String, String> _stopName;
  final String _routeID;

  String get getStopId => _id;
  Map<String, String> get getStopName => _stopName;
  String get getRouteID => _routeID;

  Stop({
    required String id,
    required Map<String, String> stopName,
    required String routeID,
  })  : _id = id,
        _stopName = stopName,
        _routeID = routeID;
}
