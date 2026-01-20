class HotelModel {
  String id;
  String name;
  String address;
  String description;
  String imageUrl;
  int price;
  List<Room> rooms;
  List<Review> reviews;
  List<Amenitie> amenities;
  double? latitude;
  double? longitude;

  HotelModel({
    this.id = '',
    this.name = '',
    this.address = '',
    this.description = '',
    this.imageUrl = '',
    this.price = 0,
    this.latitude,
    this.longitude,
    List<Room>? rooms,
    List<Review>? reviews,
    List<Amenitie>? amenities,
  })  : rooms = rooms ?? <Room>[],
        reviews = reviews ?? <Review>[],
        amenities = amenities ?? <Amenitie>[];

  HotelModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        name = json['name'] ?? '',
        price = json['price'] ?? 0,
        description = json['description'] ?? '',
        imageUrl = json['imageUrl'] ?? '',
        address = json['address'] ?? '',
        latitude = (json['latitude'] as num?)?.toDouble(),
        longitude = (json['longitude'] as num?)?.toDouble(),
        rooms = (json['rooms'] as List<dynamic>?)
                ?.map((v) => Room.fromJson(v as Map<String, dynamic>))
                .toList() ??
            <Room>[],
        reviews = (json['reviews'] as List<dynamic>?)
                ?.map((v) => Review.fromJson(v as Map<String, dynamic>))
                .toList() ??
            <Review>[],
        amenities = (json['amenities'] as List<dynamic>?)
                ?.map((v) => Amenitie.fromJson(v as Map<String, dynamic>))
                .toList() ??
            <Amenitie>[] {
    if (id.isEmpty) {
      id = '${name}_$address'
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '_');
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['description'] = description;
    data['address'] = address;
    data['imageUrl'] = imageUrl;
    if (latitude != null) {
      data['latitude'] = latitude;
    }
    if (longitude != null) {
      data['longitude'] = longitude;
    }
    data['rooms'] = rooms.map((v) => v.toJson()).toList();
    data['reviews'] = reviews.map((v) => v.toJson()).toList();
    data['amenities'] = amenities.map((v) => v.toJson()).toList();
    return data;
  }
}

class Room {
  String imageUrl;
  String name;
  String description;
  int sleeps;
  double price;

  Room({
    this.imageUrl = '', 
    this.name = '',
    this.description = '',
    this.sleeps = 0,
    this.price = 0.0,
  });

  Room.fromJson(Map<String, dynamic> json)
      : imageUrl = json['imageUrl'] ?? '',
        name = json['name'] ?? '',
        description = json['description'] ?? '',
        sleeps = json['sleeps'] ?? 0,
        price = (json['price'] ?? 0).toDouble();

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['imageUrl'] = imageUrl;
    data['name'] = name;
    data['description'] = description;
    data['sleeps'] = sleeps;
    data['price'] = price;
    return data;
  }
}

class Review {
  String message;
  String user;
  String userImage;
  int rate;

  Review({
    this.message = '',
    this.user = '',
    this.userImage = '',
    this.rate = 0,
  });

  Review.fromJson(Map<String, dynamic> json)
      : message = json['message'] ?? '',
        user = json['user'] ?? '',
        userImage = json['userImage'] ?? '',
        rate = json['rate'] ?? 0;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['user'] = user;
    data['userImage'] = userImage;
    data['rate'] = rate;
    return data;
  }
}

class Amenitie {
  String name;
  String imageUrl;

  Amenitie({this.name = '', this.imageUrl = ''});

  Amenitie.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        imageUrl = json['imageUrl'] ?? '';

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['imageUrl'] = imageUrl;
    return data;
  }
}
