class TimeTable {
  final List<bool> _serviceDay;
  final String _arrivalTime;
  final String _departureTime;

  List<bool> get getServiceDay => _serviceDay;
  String get getArrivalTime => _arrivalTime;
  String get getDeparturnnTime => _departureTime;

  TimeTable({
    required List<bool> serviceDay,
    required String arrivalTime,
    required String departureTime,
  })  : _serviceDay = serviceDay,
        _arrivalTime = arrivalTime,
        _departureTime = departureTime;
}
