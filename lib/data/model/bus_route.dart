import 'package:busapp/data/model/stop.dart';
import 'package:busapp/data/model/time_table.dart';

class BusRoute {
  final String _id;
  final Map<String, String> _routeName;
  final Map<String, String> _subtitle;
  final List<Stop> _stops;
  final int _direction;
  final List<TimeTable> _timeTables;
  final bool _provider;
  final String _ticket;

  String get getRouteId => _id;
  Map<String, String> get getRouteName => _routeName;
  Map<String, String> get getSubtitle => _subtitle;
  List<Stop> get getStops => _stops;
  int get getDirection => _direction;
  List<TimeTable> get getTimeTables => _timeTables;
  bool get getProvider => _provider;
  String get getTicket => _ticket;

  BusRoute({
    required String id,
    required Map<String, String> routeName,
    required Map<String, String> subtitle,
    required List<Stop> stops,
    required int direction,
    required List<TimeTable> timeTables,
    required bool provider,
    required String ticket,
  })  : _id = id,
        _routeName = routeName,
        _subtitle = subtitle,
        _stops = stops,
        _direction = direction,
        _timeTables = timeTables,
        _provider = provider,
        _ticket = ticket;
}
