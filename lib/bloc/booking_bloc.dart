import 'package:buscatelo/model/booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class BookingBloc extends ChangeNotifier {
  final List<BookingModel> _bookings = <BookingModel>[];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BookingModel> get bookings => List.unmodifiable(_bookings);

  BookingBloc() {
    _loadBookings();
  }

  // Load bookings from Firestore
  Future<void> _loadBookings() async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .get();

      _bookings.clear();
      for (var doc in snapshot.docs) {
        try {
          _bookings.add(BookingModel.fromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing booking: $e');
        }
      }
      
      // Sort by ID (which is timestamp) in descending order
      _bookings.sort((a, b) => b.id.compareTo(a.id));
      
      notifyListeners();
      debugPrint('Loaded ${_bookings.length} bookings from Firestore');
    } catch (e) {
      debugPrint('Error loading bookings: $e');
    }
  }

  // Add booking and save to Firestore
  Future<void> addBooking(BookingModel booking) async {
    try {
      // Save to Firestore
      await _firestore.collection('bookings').doc(booking.id).set(
            booking.toJson(),
          );

      // Add to local list
      _bookings.insert(0, booking);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving booking: $e');
      rethrow;
    }
  }

  // Refresh bookings from Firestore
  Future<void> refreshBookings() async {
    await _loadBookings();
  }
}
