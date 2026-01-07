import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StarRatingSelector extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final double size;

  const StarRatingSelector({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 40,
  });

  @override
  State<StarRatingSelector> createState() => _StarRatingSelectorState();
}

class _StarRatingSelectorState extends State<StarRatingSelector> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = starValue;
            });
            widget.onRatingChanged(starValue);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              index < _currentRating
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: index < _currentRating ? AppColors.gold : Colors.grey[300],
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }
}
