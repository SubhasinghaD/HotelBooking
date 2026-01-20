import 'dart:async';
import 'dart:convert';

import 'package:buscatelo/model/hotel_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class HotelApi {
  final String _baseUrl = 'https://raw.githubusercontent.com';
  final String _endPoint =
      '/enzoftware/hotel_booking_app/master/server/hotels.json';

  Future<List<HotelModel>> getHotels() async {
    try {
      final uri = Uri.parse(_baseUrl + _endPoint);
      final data = await http.get(uri);
      if (data.statusCode != 200) {
        throw Exception('Failed to load hotels. Status: ${data.statusCode}');
      }
      final responseList = json.decode(data.body) as List<dynamic>;
      return [
        for (final hotel in responseList)
          HotelModel.fromJson(hotel as Map<String, dynamic>)
      ];
    } catch (_) {
      final localJson = await rootBundle.loadString('server/hotels.json');
      final responseList = json.decode(localJson) as List<dynamic>;
      return [
        for (final hotel in responseList)
          HotelModel.fromJson(hotel as Map<String, dynamic>)
      ];
    }
  }
}
