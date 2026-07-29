import 'package:flutter/material.dart';

import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/booking/views/booking_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/schedule/services/booking_schedule_service.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_schedule_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/review/viewModels/review_viewmodel.dart';

class VenueDetailsPage extends StatefulWidget {
  final VenueModel venue;

  const VenueDetailsPage({super.key, required this.venue});

  @override
  State<VenueDetailsPage> createState() => _VenueDetailsPageState();
}

class _VenueDetailsPageState extends State<VenueDetailsPage> {
  int currentReview = 0;
  DateTime selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  BookingScheduleModel? schedule;

  final BookingScheduleService _scheduleService = BookingScheduleService();

  String? selectedStartTime;
  String? selectedEndTime;

  @override
  Widget build(BuildContext context) {
    final reviewVM = context.watch<ReviewViewModel>();
    final review = reviewVM.reviews.isNotEmpty
        ? reviewVM.reviews[currentReview]
        : null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.venue.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Venue Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.venue.imageUrl.isEmpty
                  ? Container(
                      height: 220,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.image, size: 80, color: Colors.grey),
                      ),
                    )
                  : Image.network(
                      widget.venue.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),

            const SizedBox(height: 24),

            Text(
              widget.venue.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.venue.address)),
              ],
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text("Open in Google Maps"),
                onPressed: () {
                  openGoogleMaps(widget.venue.address);
                },
              ),
            ),

            Row(
              children: [
                const Icon(Icons.sports_soccer),
                const SizedBox(width: 8),
                Text(widget.venue.sportType),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text(widget.venue.rating.toStringAsFixed(1)),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.attach_money),
                const SizedBox(width: 8),
                Text(
                  "RM ${widget.venue.pricePerHour}/hour",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "About",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(widget.venue.description, style: const TextStyle(height: 1.6)),

            const SizedBox(height: 30),
            const Text(
              "Reviews",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            if (review == null)
              const Text(
                "No reviews yet.",
                style: TextStyle(color: Colors.grey),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.bookerName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const Spacer(),

                        const Icon(Icons.star, color: Colors.amber),

                        Text(review.rating.toString()),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(review.comment),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: currentReview == 0
                        ? null
                        : () {
                            setState(() {
                              currentReview--;
                            });
                          },
                  ),

                  Text("${currentReview + 1} / ${reviewVM.reviews.length}"),

                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: currentReview == reviewVM.reviews.length - 1
                        ? null
                        : () {
                            setState(() {
                              currentReview++;
                            });
                          },
                  ),
                ],
              ),
            ],

            const Text(
              "Select Date",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  initialDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });

                  await loadSchedule();
                }
              },
            ),

            const SizedBox(height: 30),

            const Text(
              "Available Slots",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            schedule == null
                ? const Center(child: CircularProgressIndicator())
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: schedule!.slots.map((slot) {
                      final selected = selectedStartTime == slot.startTime;

                      final unavailable = slot.status != "available";

                      Color color = Colors.green;

                      if (slot.status == "blocked") {
                        color = Colors.orange;
                      }

                      if (slot.status == "occupied") {
                        color = Colors.red;
                      }

                      return GestureDetector(
                        onTap: unavailable
                            ? null
                            : () {
                                setState(() {
                                  selectedStartTime = slot.startTime;
                                  selectedEndTime = slot.endTime;
                                });
                              },
                        child: Container(
                          width: 110,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.blue
                                : color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? Colors.blue : color,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${slot.startTime} - ${slot.endTime}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                slot.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              if (selectedStartTime == null || selectedEndTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select a time slot.")),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingPage(
                    venue: widget.venue,
                    bookingDate: selectedDate,
                    startTime: selectedStartTime!,
                    endTime: selectedEndTime!,
                  ),
                ),
              );
            },
            child: const Text("Book Now"),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    loadSchedule();
    context.read<ReviewViewModel>().loadVenueReviews(widget.venue.id);
  }

  Future<void> loadSchedule() async {
    print("Loading schedule...");

    final data = await _scheduleService.loadSchedule(
      venueId: widget.venue.id,
      date: selectedDate,
    );

    print("Schedule loaded: $data");

    setState(() {
      schedule = data;
    });
  }

  Future<void> openGoogleMaps(String address) async {
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
