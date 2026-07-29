import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/review_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/review/viewModels/review_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/booking/viewModels/booking_viewmodel.dart';

class LeaveReviewPage extends StatefulWidget {
  final BookingModel booking;

  const LeaveReviewPage({super.key, required this.booking});

  @override
  State<LeaveReviewPage> createState() => _LeaveReviewPageState();
}

class _LeaveReviewPageState extends State<LeaveReviewPage> {
  double rating = 5;
  final TextEditingController commentController = TextEditingController();

  Future<void> submitReview() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final bookerName = userDoc.data()?["fullName"] ?? "Booker";
    final review = ReviewModel(
      id: const Uuid().v4(),
      venueId: widget.booking.venueId,
      venueName: widget.booking.venueName,
      bookerId: uid,
      bookerName: bookerName,
      rating: rating,
      comment: commentController.text.trim(),
      createdAt: DateTime.now(),
      vendorId: widget.booking.vendorId,
      reply: "",
    );

    await context.read<ReviewViewModel>().submitReview(review);
    await context.read<BookingViewModel>().markBookingAsReviewed(
      widget.booking.id,
    );

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review submitted successfully.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leave Review")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Rate your experience",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: rating.toString(),
              onChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
            ),

            Text("${rating.toInt()} Stars"),

            const SizedBox(height: 25),

            TextField(
              controller: commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Write your review...",
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitReview,
                child: const Text("Submit Review"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
