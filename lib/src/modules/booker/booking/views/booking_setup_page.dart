import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_schedule_model.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/booker/dashboard/viewModels/dashboard_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/booking/views/booking_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/review/viewModels/review_viewmodel.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/vendor/schedule/services/booking_schedule_service.dart';

class BookingSetupPage extends StatefulWidget {
  const BookingSetupPage({super.key});

  @override
  State<BookingSetupPage> createState() => _BookingSetupPageState();
}

class _BookingSetupPageState extends State<BookingSetupPage> {
  late PageController _pageController;

  VenueModel? selectedVenue;

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
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.92);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<DashboardViewModel>();

      if (vm.venues.isNotEmpty) {
        selectedVenue = vm.venues.first;

        await loadSchedule();

        if (mounted) {
          context.read<ReviewViewModel>().loadVenueReviews(selectedVenue!.id);
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadSchedule() async {
    if (selectedVenue == null) return;

    final data = await _scheduleService.loadSchedule(
      venueId: selectedVenue!.id,
      date: selectedDate,
    );

    if (!mounted) return;

    setState(() {
      schedule = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking")),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.venues.isEmpty) {
            return const Center(child: Text("No venues available"));
          }

          if (selectedVenue == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choose Venue",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 440,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: vm.venues.length,
                    onPageChanged: (index) async {
                      selectedVenue = vm.venues[index];

                      selectedStartTime = null;
                      selectedEndTime = null;
                      currentReview = 0;

                      await loadSchedule();

                      if (mounted) {
                        context.read<ReviewViewModel>().loadVenueReviews(
                          selectedVenue!.id,
                        );
                        setState(() {});
                      }
                    },
                    itemBuilder: (context, index) {
                      final venue = vm.venues[index];

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: venue.imageUrl.isEmpty
                                  ? Container(
                                      height: 220,
                                      width: double.infinity,
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Image.network(
                                      venue.imageUrl,
                                      height: 220,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    venue.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const Icon(Icons.chevron_right),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                const Icon(Icons.location_on),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    venue.address,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                // Copy onPressed daripada VenueDetailsPage
                              },
                              icon: const Icon(Icons.map_outlined),
                              label: const Text("Open in Google Maps"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(vm.venues.length, (index) {
                    final active = selectedVenue?.id == vm.venues[index].id;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 30),
                Row(
                  children: [
                    const Icon(Icons.sports_soccer),
                    const SizedBox(width: 8),
                    Text(selectedVenue!.sportType),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(selectedVenue!.rating.toStringAsFixed(1)),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.attach_money),
                    const SizedBox(width: 8),
                    Text(
                      "RM ${selectedVenue!.pricePerHour}/hour",
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

                Text(selectedVenue!.description),

                const SizedBox(height: 30),

                const Text(
                  "Reviews",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Consumer<ReviewViewModel>(
                  builder: (context, reviewVM, child) {
                    final review = reviewVM.reviews.isNotEmpty
                        ? reviewVM.reviews[currentReview.clamp(
                            0,
                            reviewVM.reviews.length - 1,
                          )]
                        : null;

                    if (review == null) {
                      return const Text(
                        "No reviews yet.",
                        style: TextStyle(color: Colors.grey),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
                            Text(
                              "${currentReview + 1} / ${reviewVM.reviews.length}",
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed:
                                  currentReview == reviewVM.reviews.length - 1
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
                    );
                  },
                ),

                const SizedBox(height: 30),

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
                      initialDate: selectedDate,
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
                                    : color.withOpacity(.15),
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
          );
        },
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: () async {
              if (selectedVenue == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select a venue.")),
                );
                return;
              }

              if (selectedStartTime == null || selectedEndTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select a time slot.")),
                );
                return;
              }

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingPage(
                    venue: selectedVenue!,
                    bookingDate: selectedDate,
                    startTime: selectedStartTime!,
                    endTime: selectedEndTime!,
                  ),
                ),
              );

              // Refresh the Home tab's "My Bookings" preview so it reflects
              // any booking created/cancelled while on the BookingPage,
              // instead of showing stale data from initial page load.
              if (mounted) {
                context.read<DashboardViewModel>().loadLatestBookings();
              }
            },
            child: const Text("Continue"),
          ),
        ),
      ),
    );
  }
}
