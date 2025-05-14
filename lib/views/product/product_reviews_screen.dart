import 'package:ecommerce_computer_client/consts/colors.dart';
import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/widgets/appbar.dart';
import 'package:flutter/material.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,

      /// 1. AppBar
      appBar: const TAppBar(
        title: Text(
          'Reviews & Ratings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        showBackArrow: true,
      ),

      /// 2. Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 2.1 Description
              const Text(
                "Ratings and reviews are verified and are from people who use the same type of device that you use.",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),

              /// 2.2 Overall Rating Section
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Numerical Rating
                  const Text(
                    '4.8',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 46,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Star Rating
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: Sizes.spaceBtwItems),

              /// 2.3 Rating Distribution (Progress Bars)
              Column(
                children: [
                  _buildRatingBar(context, 5, 0.7),
                  _buildRatingBar(context, 4, 0.2),
                  _buildRatingBar(context, 3, 0.05),
                  _buildRatingBar(context, 2, 0.03),
                  _buildRatingBar(context, 1, 0.02),
                ],
              ),
              const SizedBox(height: Sizes.spaceBtwSections),

              /// 2.4 Reviews List
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3, // Example: 3 reviews
                    separatorBuilder:
                        (context, index) =>
                            const SizedBox(height: Sizes.spaceBtwItems),
                    itemBuilder: (context, index) {
                      return _buildReviewCard(
                        username: 'John Doe',
                        rating: 4.5,
                        date: 'May 14, 2025',
                        reviewText:
                            'Great laptop! The performance is amazing for gaming, and the battery life is decent. However, it gets a bit warm during extended use.',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to build a rating bar row (e.g., "5" + progress bar)
  Widget _buildRatingBar(BuildContext context, int starCount, double progress) {
    return Row(
      children: [
        Text(
          '$starCount',
          style: const TextStyle(fontSize: 14, color: darkFontGrey),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            borderRadius: BorderRadius.circular(8),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// Helper to build a review card
  Widget _buildReviewCard({
    required String username,
    required double rating,
    required String date,
    required String reviewText,
  }) {
    return Container(
      padding: const EdgeInsets.all(Sizes.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: Sizes.sm),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating.floor() ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
          ),
          const SizedBox(height: Sizes.sm),
          Text(
            reviewText,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
