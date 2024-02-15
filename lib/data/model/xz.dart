class Temperatures {
  bool success;
  int statusCode;
  String message;
  List<Datum> data;

  Temperatures({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

}

class Datum {
  int? orderId;
  int? driverId;
  int pointId;
  List<Item> items;

  Datum({
    required this.orderId,
    required this.driverId,
    required this.pointId,
    required this.items,
  });

}

class Item {
  String code;
  int status;

  Item({
    required this.code,
    required this.status,
  });
}