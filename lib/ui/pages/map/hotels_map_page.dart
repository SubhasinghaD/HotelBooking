import 'dart:async';
import 'package:buscatelo/commons/theme.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:buscatelo/ui/pages/hotel_detail/hotel_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HotelsMapPage extends StatefulWidget {
  final List<HotelModel> hotels;

  const HotelsMapPage({Key? key, required this.hotels}) : super(key: key);

  @override
  State<HotelsMapPage> createState() => _HotelsMapPageState();
}

class _HotelsMapPageState extends State<HotelsMapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  HotelModel? _selectedHotel;

  // Default center - Sri Lanka
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.9271, 79.8612), // Colombo, Sri Lanka
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    final markers = <Marker>{};
    
    for (var hotel in widget.hotels) {
      if (hotel.latitude != null && hotel.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(hotel.id),
            position: LatLng(hotel.latitude!, hotel.longitude!),
            infoWindow: InfoWindow(
              title: hotel.name,
              snippet: 'LKR ${hotel.price}/night',
              onTap: () {
                setState(() {
                  _selectedHotel = hotel;
                });
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            onTap: () {
              setState(() {
                _selectedHotel = hotel;
              });
            },
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });

    // Center map on first hotel with coordinates
    if (widget.hotels.isNotEmpty) {
      final firstHotel = widget.hotels.firstWhere(
        (h) => h.latitude != null && h.longitude != null,
        orElse: () => widget.hotels.first,
      );
      if (firstHotel.latitude != null && firstHotel.longitude != null) {
        _moveCamera(LatLng(firstHotel.latitude!, firstHotel.longitude!));
      }
    }
  }

  Future<void> _moveCamera(LatLng position) async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels Map'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (widget.hotels.isNotEmpty) {
                final firstHotel = widget.hotels.firstWhere(
                  (h) => h.latitude != null && h.longitude != null,
                  orElse: () => widget.hotels.first,
                );
                if (firstHotel.latitude != null && firstHotel.longitude != null) {
                  _moveCamera(LatLng(firstHotel.latitude!, firstHotel.longitude!));
                }
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
          ),
          // Selected hotel card
          if (_selectedHotel != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildHotelCard(_selectedHotel!),
            ),
          // Hotel count badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${_markers.length} Hotels',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(HotelModel hotel) {
    final rating = hotel.reviews.isEmpty
        ? 0.0
        : hotel.reviews.fold<int>(0, (sum, r) => sum + r.rate) /
            hotel.reviews.length;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HotelDetailPage(hotel),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Hotel image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  hotel.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/img/hotel1.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Hotel details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hotel.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'LKR ${hotel.price}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Arrow icon
              Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  color: Colors.white,
                  iconSize: 20,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HotelDetailPage(hotel),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
