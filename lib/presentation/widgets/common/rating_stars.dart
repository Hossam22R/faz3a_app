import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    required this.rating,
    this.maxStars = 5,
    this.size = 16,
    super.key,
  });

  final double rating;
  final int maxStars;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(maxStars, (int index) {
        final int star = index + 1;
        final IconData icon;
        if (rating >= star) {
          icon = Icons.star_rounded;
        } else if (rating > index && rating < star) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        return Icon(icon, size: size, color: Colors.amber);
      }),
    );
  }
}
