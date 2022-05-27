class FilterData {
  static List<String> _getAllRouteName() {
    return ["525", "1688", "6700", "6914", "13路", "校內巡迴專車"];
  }

  static List<String> _getStop() {
    return ["二水", "員林", "大村火車站", "花壇", "彰化", "高鐵彰化站"];
  }

  static List<List<String>> getFilterData() {
    return [
      _getStop(),
      _getAllRouteName(),
    ];
  }
}
