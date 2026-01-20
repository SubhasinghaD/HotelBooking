import 'package:buscatelo/model/hotel_model.dart';
import 'package:flutter/foundation.dart';

class FavoritesBloc extends ChangeNotifier {
  final Set<String> _favoriteIds = <String>{};

  bool isFavorite(HotelModel hotel) => _favoriteIds.contains(hotel.id);

  List<String> get favoriteIds => _favoriteIds.toList(growable: false);

  void toggleFavorite(HotelModel hotel) {
    if (_favoriteIds.contains(hotel.id)) {
      _favoriteIds.remove(hotel.id);
    } else {
      _favoriteIds.add(hotel.id);
    }
    notifyListeners();
  }
}
