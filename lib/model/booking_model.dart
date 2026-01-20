class BookingModel {
  final String id;
  final String hotelId;
  final String hotelName;
  final String roomName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int totalPrice;
  final String status;

  BookingModel({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.roomName,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'roomName': roomName,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'guests': guests,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Create from Firestore JSON
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String,
      hotelName: json['hotelName'] as String,
      roomName: json['roomName'] as String,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      guests: json['guests'] as int,
      totalPrice: json['totalPrice'] as int,
      status: json['status'] as String,
    );
  }
}
