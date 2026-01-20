import 'package:buscatelo/model/booking_model.dart';
import 'package:flutter/foundation.dart';

class BookingBloc extends ChangeNotifier {
  final List<BookingModel> _bookings = <BookingModel>[];

  List<BookingModel> get bookings => List.unmodifiable(_bookings);

  void addBooking(BookingModel booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }
}
