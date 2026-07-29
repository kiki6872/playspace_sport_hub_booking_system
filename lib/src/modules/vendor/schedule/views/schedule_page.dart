import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/schedule/viewModels/booking_schedule_viewmodel.dart';

class VendorSchedulePage extends StatefulWidget {
  const VendorSchedulePage({super.key});

  @override
  State<VendorSchedulePage> createState() => _VendorSchedulePageState();
}

IconData getSportIcon(String sport) {
  switch (sport.toLowerCase()) {
    case "basketball":
      return Icons.sports_basketball;

    case "badminton":
      return Icons.sports_tennis;

    case "football":
      return Icons.sports_soccer;

    case "futsal":
      return Icons.sports_soccer;

    case "tennis":
      return Icons.sports_tennis;

    default:
      return Icons.sports;
  }
}

class _VendorSchedulePageState extends State<VendorSchedulePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final vm = context.read<BookingScheduleViewModel>();

      await vm.loadBookings();

      await vm.loadVendorVenues();

      await vm.loadSchedule();
    });
  }

  Future<void> pickDate() async {
    final vm = context.read<BookingScheduleViewModel>();

    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    vm.selectDate(picked);

    await vm.loadSchedule();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingScheduleViewModel>();

    return DefaultTabController(
      length: 2,

      child: Scaffold(
        appBar: AppBar(
          title: const Text("Schedule"),

          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_month), text: "Bookings"),

              Tab(icon: Icon(Icons.schedule), text: "Availability"),
            ],
          ),
        ),

        body: TabBarView(
          children: [_buildBookings(vm), _buildAvailability(vm)],
        ),
      ),
    );
  }

  ///=========================================================
  /// BOOKING TAB
  ///=========================================================

  Widget _buildBookings(BookingScheduleViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.bookings.isEmpty) {
      return const Center(child: Text("No bookings yet."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.bookings.length,
      itemBuilder: (context, index) {
        final booking = vm.bookings[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Venue
                Row(
                  children: [
                    Icon(getSportIcon(booking.sportType)),

                    const SizedBox(width: 8),

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

                const SizedBox(height: 12),

                /// Booker
                Row(
                  children: [
                    const Icon(Icons.person),

                    const SizedBox(width: 8),

                    Text(booking.bookerName),
                  ],
                ),

                const SizedBox(height: 8),

                /// Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today),

                    const SizedBox(width: 8),

                    Text(DateFormat("dd MMM yyyy").format(booking.bookingDate)),
                  ],
                ),

                const SizedBox(height: 8),

                /// Time
                Row(
                  children: [
                    const Icon(Icons.access_time),

                    const SizedBox(width: 8),

                    Text("${booking.startTime} - ${booking.endTime}"),
                  ],
                ),

                const SizedBox(height: 8),

                /// Price
                Row(
                  children: [
                    const Icon(Icons.attach_money),

                    const SizedBox(width: 8),

                    Text("RM ${booking.totalPrice.toStringAsFixed(2)}"),
                  ],
                ),

                const SizedBox(height: 16),

                Chip(
                  backgroundColor: booking.status == "approved"
                      ? Colors.green
                      : booking.status == "rejected"
                      ? Colors.red
                      : Colors.orange,

                  label: Text(
                    booking.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 16),

                if (booking.status == "pending")
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            vm.approveBooking(booking.id);
                          },
                          child: const Text("Approve"),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            vm.rejectBooking(booking.id);
                          },
                          child: const Text("Reject"),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  ///=========================================================
  /// AVAILABILITY TAB
  ///=========================================================

  Widget _buildAvailability(BookingScheduleViewModel vm) {
    if (vm.selectedVenue == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Venue
          const Text(
            "Venue",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<VenueModel>(
            value: vm.selectedVenue,

            decoration: const InputDecoration(border: OutlineInputBorder()),

            items: vm.venues.map((venue) {
              return DropdownMenuItem(value: venue, child: Text(venue.name));
            }).toList(),

            onChanged: (venue) async {
              if (venue == null) return;

              vm.selectVenue(venue);

              await vm.loadSchedule();
            },
          ),

          const SizedBox(height: 30),

          /// Date
          const Text(
            "Booking Date",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat("dd MMM yyyy").format(vm.selectedDate)),
              onTap: pickDate,
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Manage Slots",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 15),

          if (vm.schedule == null)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: vm.schedule!.slots.map((slot) {
                Color color = Colors.green;

                if (slot.status == "blocked") {
                  color = Colors.orange;
                }

                if (slot.status == "booked") {
                  color = Colors.red;
                }

                final selected = vm.selectedSlot?.id == slot.id;

                return GestureDetector(
                  onTap: () {
                    vm.selectSlot(slot);
                  },

                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(vertical: 14),

                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: selected ? Colors.blue : color.withOpacity(.15),

                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(color: selected ? Colors.blue : color),
                    ),

                    child: Column(
                      children: [
                        Text(
                          "${slot.startTime}\n${slot.endTime}",
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 5),

                        Text(
                          slot.status.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 30),

          if (vm.selectedSlot != null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.block),

                    onPressed: () async {
                      await vm.blockSelectedSlot();
                    },

                    label: const Text("Block Slot"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),

                    icon: const Icon(Icons.check),

                    onPressed: () async {
                      await vm.unblockSelectedSlot();
                    },

                    label: const Text("Unblock"),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
