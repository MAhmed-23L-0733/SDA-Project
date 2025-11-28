class Tickets {
  int? routeId;
  double? price;
  int? status;
  int? seatNumber;
  int? way; //one way or round trip

  Tickets({
    required this.routeId,
    required this.price,
    required this.status,
    required this.seatNumber,
    required this.way,
  });
  factory Tickets.fromJson(Map<String, dynamic> json) {
    return Tickets(
      routeId: json['route_id'],
      price: (json['price'] as num).toDouble(),
      status: json['status'],
      seatNumber: json['seat_number'],
      way: json['way'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'price': price,
      'status': status,
      'seat_number': seatNumber,
      'way': way,
    };
  }
}
