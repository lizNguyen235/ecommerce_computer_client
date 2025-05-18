import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/consts/colors.dart';
import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/core/service/AuthService.dart';
import 'package:ecommerce_computer_client/core/service/UserService.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/login/login.dart';
import 'package:ecommerce_computer_client/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductReviewsScreen extends StatefulWidget {
  final String productId;

  const ProductReviewsScreen({super.key, required this.productId});

  @override
  _ProductReviewsScreenState createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final RxDouble _rating = 0.0.obs;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<bool> _hasUserReviewed() async {
    final user = _authService.getCurrentUser();
    if (user == null) return false; // Anonymous users can submit multiple times if allowed

    final querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .collection('reviews')
        .where('userId', isEqualTo: user.uid)
        .get();

    return querySnapshot.docs.isNotEmpty; // If there are documents, the user has reviewed
  }

  void _submitReview() async {
    final user = _authService.getCurrentUser();
    final comment = _commentController.text.trim();
    final rating = _rating.value;

    if (comment.isEmpty && rating == 0) {
      Get.snackbar('Error', 'Please enter a comment or rating.',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red.shade500, colorText: whiteColor);
      return;
    }

    if (rating > 0 && user == null) {
      Get.snackbar('Error', 'Please log in to rate.',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red.shade500, colorText: whiteColor);
      Get.to(() => LoginDialog());
      return;
    }

    // Check if the user has already reviewed
    if (user != null) {
      final hasReviewed = await _hasUserReviewed();
      if (hasReviewed) {
        Get.snackbar('Error', 'You have already reviewed this product. Each user can only review once.',
            snackPosition: SnackPosition.TOP, backgroundColor: Colors.red.shade500, colorText: whiteColor);
        return;
      }
    }

    String username = 'Anonymous';
    if (user != null) {
      final userData = await _userService.getUserProfile(user.uid);
      username = userData?['fullName'] ?? 'User';
    }

    final review = {
      'userId': user?.uid,
      'username': username,
      'comment': comment.isNotEmpty ? comment : null,
      'rating': rating > 0 ? rating : null,
      'timestamp': Timestamp.now(),
    };

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .collection('reviews')
        .add(review);

    // Update aggregate data
    final productRef = FirebaseFirestore.instance.collection('products').doc(widget.productId);
    final snapshot = await productRef.collection('reviews').get();
    final ratings = snapshot.docs
        .where((doc) => doc['rating'] != null)
        .map((doc) => doc['rating'] as num)
        .toList();
    final averageRating = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;
    await productRef.update({
      'averageRating': averageRating,
      'reviewCount': snapshot.docs.length,
    });

    // Clear input fields
    _commentController.clear();
    _rating.value = 0.0;
    Get.snackbar('Success', 'Review submitted!', snackPosition: SnackPosition.TOP, backgroundColor: Colors.green.shade500, colorText: whiteColor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: const TAppBar(
        title: Text('Reviews & Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Reviews and comments are verified and come from users using the same device type as you.",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('products').doc(widget.productId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  final averageRating = data?['averageRating']?.toDouble() ?? 0.0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 46, color: Colors.black),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < averageRating.floor() ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.productId)
                    .collection('reviews')
                    .where('rating', isNotEqualTo: null)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final ratings = snapshot.data!.docs
                      .map((doc) => (doc['rating'] as num?) ?? 0.0)
                      .toList();
                  final ratingCounts = List.filled(5, 0);
                  for (var rating in ratings) {
                    if (rating >= 1 && rating <= 5) ratingCounts[rating.floor() - 1]++;
                  }
                  final totalRatings = ratings.length;
                  return Column(
                    children: List.generate(5, (index) {
                      final starCount = 5 - index;
                      final progress = totalRatings > 0 ? ratingCounts[starCount - 1] / totalRatings : 0.0;
                      return _buildRatingBar(context, starCount, progress);
                    }),
                  );
                },
              ),
              const SizedBox(height: Sizes.spaceBtwSections),
              const Text(
                'Write a Review',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Your comment',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Sizes.borderRadiusMd)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              Obx(() => Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating.value.floor() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 30,
                    ),
                    onPressed: () {
                      if (_authService.getCurrentUser() == null) {
                        Get.snackbar('Error', 'Please log in to rate.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red.shade500,
                            colorText: whiteColor);
                        Get.to(() => LoginDialog());
                      } else {
                        _rating.value = (index + 1).toDouble();
                      }
                    },
                    tooltip: 'Rate ${index + 1} stars',
                  );
                }),
              )),
              const SizedBox(height: Sizes.spaceBtwItems),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: Sizes.md),
                    backgroundColor: TColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.buttonRadius)),
                  ),
                  child: const Text(
                    'Submit Review',
                    style: TextStyle(fontSize: 16, color: whiteColor, fontFamily: bold),
                  ),
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),
              const Text(
                'User Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.productId)
                    .collection('reviews')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No reviews yet.', style: TextStyle(color: darkFontGrey));
                  }
                  final reviews = snapshot.data!.docs;
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    separatorBuilder: (context, index) => const SizedBox(height: Sizes.spaceBtwItems),
                    itemBuilder: (context, index) {
                      final review = reviews[index].data() as Map<String, dynamic>;
                      return _buildReviewCard(
                        username: review['username'],
                        rating: (review['rating'] as num?)?.toDouble() ?? 0.0,
                        date: DateTime.fromMillisecondsSinceEpoch(
                            (review['timestamp'] as Timestamp).millisecondsSinceEpoch)
                            .toString()
                            .substring(0, 10),
                        reviewText: review['comment'] ?? '',
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context, int starCount, double progress) {
    return Row(
      children: [
        Text('$starCount', style: const TextStyle(fontSize: 14, color: darkFontGrey)),
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

  Widget _buildReviewCard({
    required String username,
    required double rating,
    required String date,
    required String reviewText,
  }) {
    return Container(
      padding: const EdgeInsets.all(Sizes.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
          if (rating > 0) ...[
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
          ],
          if (reviewText.isNotEmpty) ...[
            const SizedBox(height: Sizes.sm),
            Text(
              reviewText,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ],
      ),
    );
  }
}