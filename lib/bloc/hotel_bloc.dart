import 'package:buscatelo/data/network/failure_error_handler.dart';
import 'package:buscatelo/data/repository/hotel_repository.dart';
import 'package:buscatelo/data/repository/remote_hotel_repository.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HotelBloc extends ChangeNotifier {
  HotelBloc({required this.firebaseReady});

  final bool firebaseReady;
  HotelRepository repository = RemoteHotelRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Private list of [HotelModel]
  List<HotelModel> _hotels = <HotelModel>[];

  /// Public getter for hotels
  List<HotelModel> get hotels => _hotels;

  /// [Failure] instance
  Failure? _failure;
  Failure? get failure => _failure;

  void retrieveHotels() async {
    try {
      if (firebaseReady) {
        final snapshot = await _firestore.collection('hotels').get();
        _hotels = snapshot.docs
            .map((doc) => HotelModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();
      } else {
        _hotels = await repository.fetchHotels();
      }
      _failure = null;
    } on Failure catch (e) {
      _failure = e;
    } catch (e) {
      _failure = Failure(e.toString(), 500);
    }
    notifyListeners();
  }
}
