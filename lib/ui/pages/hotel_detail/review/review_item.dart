import 'package:buscatelo/model/hotel_model.dart';
import 'package:flutter/material.dart';

class ReviewItem extends StatelessWidget {
  final Review review;
  const ReviewItem({
    Key? key,
    required this.review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(
          review.userImage,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 40,
            height: 40,
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: Icon(Icons.person, color: Colors.grey),
          ),
        ),
        title: Text(review.message),
        subtitle: Text(review.user),
        trailing: Text(review.rate.toString()),
      ),
    );
  }
}
