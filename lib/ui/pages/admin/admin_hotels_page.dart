import 'package:buscatelo/model/hotel_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:buscatelo/app/app_config.dart';
import 'dart:typed_data';
import 'dart:async';

class AdminHotelsPage extends StatelessWidget {
  const AdminHotelsPage({Key? key}) : super(key: key);

  String _resolveStorageBucket() {
    final bucket = Firebase.app().options.storageBucket;
    if (bucket != null && bucket.isNotEmpty) return bucket;
    return AppConfig.firebaseWebStorageBucket;
  }

  Future<void> _showHotelDialog(BuildContext context,
      {HotelModel? hotel, String? docId}) async {
    final nameController = TextEditingController(text: hotel?.name ?? '');
    final addressController =
        TextEditingController(text: hotel?.address ?? '');
    final priceController = TextEditingController(
        text: hotel != null ? hotel.price.toString() : '');
    final descriptionController =
        TextEditingController(text: hotel?.description ?? '');
    String? selectedImageUrl = hotel?.imageUrl;
    Uint8List? selectedImageBytes;
    final latitudeController = TextEditingController(
        text: hotel?.latitude?.toString() ?? '');
    final longitudeController = TextEditingController(
        text: hotel?.longitude?.toString() ?? '');

    final rooms = List<Room>.from(hotel?.rooms ?? <Room>[]);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(hotel == null ? 'Add Hotel' : 'Edit Hotel'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Hotel name'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price (LKR)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                if (selectedImageBytes != null)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          selectedImageBytes!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
                else if (selectedImageUrl != null && selectedImageUrl!.isNotEmpty)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          selectedImageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 150,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: Text(selectedImageBytes != null || (selectedImageUrl != null && selectedImageUrl!.isNotEmpty) ? 'Change Image' : 'Select Hotel Image'),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                      maxWidth: 1280,
                    );
                    if (pickedFile != null) {
                      final bytes = await pickedFile.readAsBytes();
                      setDialogState(() {
                        selectedImageBytes = bytes;
                      });
                    }
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latitudeController,
                        decoration: const InputDecoration(labelText: 'Latitude'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: longitudeController,
                        decoration: const InputDecoration(labelText: 'Longitude'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rooms',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final room = await _showRoomDialog(context);
                        if (room != null) {
                          setDialogState(() => rooms.add(room));
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Room'),
                    ),
                  ],
                ),
                for (final room in rooms)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(room.name),
                    subtitle: Text('LKR ${room.price} • Sleeps ${room.sleeps}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setDialogState(() => rooms.remove(room)),
                    ),
                  ),
              ],
            ),
          ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );

                  final price = int.tryParse(priceController.text.trim()) ?? 0;
                  final latitude = double.tryParse(latitudeController.text.trim());
                  final longitude = double.tryParse(longitudeController.text.trim());

                  if (selectedImageBytes == null) {
                    navigator.pop();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Please select an image.')),
                    );
                    return;
                  }

                  String uploadedImageUrl = '';
                  try {
                    final bucket = _resolveStorageBucket();
                    debugPrint('Using storage bucket: $bucket');
                    debugPrint('Starting hotel image upload...');
                    final storageRef = FirebaseStorage.instanceFor(
                      bucket: bucket,
                    )
                        .ref()
                        .child('hotels')
                        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

                    final uploadTask = storageRef.putData(
                      selectedImageBytes!,
                      SettableMetadata(contentType: 'image/jpeg'),
                    );

                    uploadTask.snapshotEvents.listen((snapshot) {
                      debugPrint(
                        'Hotel upload: ${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes',
                      );
                    }, onError: (error) {
                      debugPrint('Hotel upload error: $error');
                    });

                    final snapshot = await uploadTask;
                    uploadedImageUrl = await snapshot.ref.getDownloadURL();
                    debugPrint('Hotel image uploaded. URL: $uploadedImageUrl');
                  } catch (uploadError) {
                    navigator.pop();
                    debugPrint('Hotel image upload failed: $uploadError');
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Image upload failed: $uploadError')),
                    );
                    return;
                  }

                  print('Saving hotel to Firestore...');
                  final updated = HotelModel(
                    id: docId ?? '',
                    name: nameController.text.trim(),
                    address: addressController.text.trim(),
                    price: price,
                    description: descriptionController.text.trim(),
                    imageUrl: uploadedImageUrl,
                    latitude: latitude,
                    longitude: longitude,
                    rooms: rooms,
                  );

                  debugPrint('Saving hotel to Firestore...');
                  final hotelsRef = FirebaseFirestore.instance.collection('hotels');
                  final id = docId ?? hotelsRef.doc().id;
                  await hotelsRef.doc(id).set(updated.toJson());
                  debugPrint('Hotel saved successfully.');
                  print('Hotel saved successfully!');
                  
                  // Close loading dialog
                  navigator.pop();
                  // Close hotel dialog
                  navigator.pop();
                  
                  // Show success message
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Hotel saved successfully!')),
                  );
                } catch (e) {
                  print('Error saving hotel: $e');
                  // Close loading dialog if open
                  try {
                    navigator.pop();
                  } catch (_) {}
                  // Show error message
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error saving hotel: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Room?> _showRoomDialog(BuildContext context) async {
    final nameController = TextEditingController();
    String? selectedImageUrl;
    Uint8List? selectedImageBytes;
    final priceController = TextEditingController();
    final sleepsController = TextEditingController();
    final descriptionController = TextEditingController();

    return showDialog<Room>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Room'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Room name'),
                ),
                const SizedBox(height: 16),
                if (selectedImageBytes != null)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          selectedImageBytes!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: Text(selectedImageBytes != null ? 'Change Image' : 'Select Room Image'),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                      maxWidth: 1280,
                    );
                    if (pickedFile != null) {
                      final bytes = await pickedFile.readAsBytes();
                      setDialogState(() {
                        selectedImageBytes = bytes;
                      });
                    }
                  },
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price (LKR)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: sleepsController,
                decoration: const InputDecoration(labelText: 'Sleeps'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
            ],
          ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              try {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                final price = double.tryParse(priceController.text.trim()) ?? 0;
                final sleeps = int.tryParse(sleepsController.text.trim()) ?? 0;
                
                String uploadedImageUrl = '';
                
                // Upload room image to Firebase Storage if selected
                if (selectedImageBytes != null) {
                  try {
                    final bucket = _resolveStorageBucket();
                    debugPrint('Using storage bucket: $bucket');
                    print('Starting room image upload...');
                    final storageRef = FirebaseStorage.instanceFor(
                      bucket: bucket,
                    )
                        .ref()
                        .child('rooms')
                        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
                    
                    final uploadTask = storageRef.putData(
                      selectedImageBytes!,
                      SettableMetadata(contentType: 'image/jpeg'),
                    );

                    uploadTask.snapshotEvents.listen((snapshot) {
                      debugPrint(
                        'Room upload: ${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes',
                      );
                    }, onError: (error) {
                      debugPrint('Room upload error: $error');
                    });
                    
                    final snapshot = await uploadTask;
                    uploadedImageUrl = await snapshot.ref.getDownloadURL();
                    print('Room image uploaded successfully: $uploadedImageUrl');
                  } catch (uploadError) {
                    print('Room image upload failed: $uploadError');
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Image upload failed: $uploadError')),
                    );
                  }
                }
                
                // Close loading dialog
                navigator.pop();
                
                // Close room dialog with the room data
                navigator.pop(
                  Room(
                    name: nameController.text.trim(),
                    imageUrl: uploadedImageUrl,
                    price: price,
                    sleeps: sleeps,
                    description: descriptionController.text.trim(),
                  ),
                );
              } catch (e) {
                // Close loading dialog if open
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error saving room: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _deleteHotel(BuildContext context, String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete hotel?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('hotels').doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('hotels')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hotels found.'));
          }

          final docs = snapshot.data!.docs;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final hotel = HotelModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              });
              final avgRating = hotel.reviews.isNotEmpty
                  ? hotel.reviews.map((r) => r.rate).reduce((a, b) => a + b) /
                      hotel.reviews.length
                  : 0.0;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        hotel.imageUrl.isNotEmpty
                            ? Image.network(
                                hotel.imageUrl,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 120,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.hotel, size: 48),
                                ),
                              )
                            : Container(
                                height: 120,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.hotel, size: 48),
                              ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  avgRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hotel.address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'LKR ${hotel.price}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const Text(
                                '/night',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Edit'),
                                  onPressed: () => _showHotelDialog(context,
                                      hotel: hotel, docId: doc.id),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteHotel(context, doc.id),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHotelDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
