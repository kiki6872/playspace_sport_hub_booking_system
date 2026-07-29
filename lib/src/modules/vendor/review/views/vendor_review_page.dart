import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/models/review_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/review/viewModels/review_viewmodel.dart';

class VendorReviewPage extends StatefulWidget {
  const VendorReviewPage({super.key});

  @override
  State<VendorReviewPage> createState() => _VendorReviewPageState();
}

class _VendorReviewPageState extends State<VendorReviewPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ReviewViewModel>().loadVendorReviews();
    });
  }

  Future<void> showReplyDialog(ReviewModel review) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Reply Review"),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(hintText: "Write your reply..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read<ReviewViewModel>().replyReview(
                  reviewId: review.id,
                  reply: controller.text.trim(),
                );

                if (!mounted) return;

                Navigator.pop(context);
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.reviews.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Customer Reviews")),
        body: const Center(child: Text("No reviews yet.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Customer Reviews")),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vm.reviews.length,
        itemBuilder: (context, index) {
          final review = vm.reviews[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.bookerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text("${review.rating} ⭐"),

                  const SizedBox(height: 10),

                  Text(review.comment),
                  const SizedBox(height: 15),

                  if (review.reply.isEmpty)
                    ElevatedButton(
                      onPressed: () {
                        showReplyDialog(review);
                      },
                      child: const Text("Reply"),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Vendor Reply",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(review.reply),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
