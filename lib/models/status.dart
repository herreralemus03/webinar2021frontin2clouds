class Status {
  String title;
  int value;
  Status({required this.title, required this.value});
}

class Response {
  bool stopped;
  List<Status> values;

  Response({required this.stopped, required this.values});
}
