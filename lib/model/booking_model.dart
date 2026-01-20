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
}
