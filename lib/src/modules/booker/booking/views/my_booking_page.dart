import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/booker/booking/viewModels/booking_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/confirmation_dialog.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/review/views/leave_review_page.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<BookingViewModel>().loadBookerBookings();
    });
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    await showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: "Cancel Booking",
        message: "Are you sure you want to cancel this booking?",
        confirmButtonText: "Yes",
        cancelButtonText: "No",
        onConfirm: () async {
          Navigator.pop(context);

          await context.read<BookingViewModel>().cancelBooking(booking);

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Booking cancelled successfully.")),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),

      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: "Upcoming"),
                      Tab(text: "Completed"),
                      Tab(text: "Cancelled"),
                    ],
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        buildBookingList("upcoming"),
                        buildBookingList("completed"),
                        buildBookingList("cancelled"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildBookingList(String type) {
    final vm = context.watch<BookingViewModel>();

    List<BookingModel> bookings;

    switch (type) {
      case "completed":
        bookings = vm.bookings.where((e) => e.status == "completed").toList();
        break;

      case "cancelled":
        bookings = vm.bookings.where((e) => e.status == "cancelled").toList();
        break;

      default:
        bookings = vm.bookings
            .where((e) => e.status != "completed" && e.status != "cancelled")
            .toList();
    }

    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey),
            SizedBox(height: 15),
            Text(
              "No bookings found",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return buildBookingCard(bookings[index]);
      },
    );
  }

  Widget buildBookingCard(BookingModel booking) {
    final today = DateTime.now();

    final now = DateTime(today.year, today.month, today.day);

    final bookingDate = DateTime(
      booking.bookingDate.year,
      booking.bookingDate.month,
      booking.bookingDate.day,
    );

    final days = bookingDate.difference(now).inDays;

    final canCancel =
        booking.status != "cancelled" &&
        booking.status != "completed" &&
        days >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sports_soccer, size: 28),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    booking.venueName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                const Icon(Icons.calendar_month, size: 18),

                const SizedBox(width: 8),

                Text(DateFormat("dd MMM yyyy").format(booking.bookingDate)),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.access_time, size: 18),

                const SizedBox(width: 8),

                Text("${booking.startTime} - ${booking.endTime}"),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.attach_money, size: 18),

                const SizedBox(width: 8),

                Text("RM ${booking.totalPrice.toStringAsFixed(2)}"),
              ],
            ),

            const SizedBox(height: 16),

            Builder(
              builder: (_) {
                String label;
                Color color;

                if (booking.status == "cancelled") {
                  label = "Cancelled";
                  color = Colors.red;
                } else if (booking.status == "completed") {
                  label = "Completed";
                  color = Colors.blueGrey;
                } else if (days == 0) {
                  label = "Today";
                  color = Colors.green;
                } else if (days == 1) {
                  label = "Tomorrow";
                  color = Colors.green;
                } else if (days > 1) {
                  label = "In $days days";
                  color = Colors.orange;
                } else {
                  label = "Awaiting Completion";
                  color = Colors.deepOrange;
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            if (canCancel) ...[
              const Divider(),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelBooking(booking),
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel Booking"),
                ),
              ),
            ],

            if (booking.status == "completed" && !booking.isReviewed) ...[
              const Divider(),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LeaveReviewPage(booking: booking),
                      ),
                    );
                  },
                  icon: const Icon(Icons.star),
                  label: const Text("Leave Review"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
