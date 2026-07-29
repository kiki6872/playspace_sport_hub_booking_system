import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:playspace_sport_hub_booking_system/src/models/match_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/match/viewModels/match_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/schedule/services/booking_schedule_service.dart';
import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';
import 'package:playspace_sport_hub_booking_system/src/models/booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/booking/viewModels/booking_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/models/user_voucher_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/reward/services/reward_service.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/booking_summary_dialog.dart';
import 'package:playspace_sport_hub_booking_system/src/enums/booking_type.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/payment_method_selector.dart';

class BookingPage extends StatefulWidget {
  final VenueModel venue;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;

  const BookingPage({
    super.key,

    required this.venue,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int maximumPlayers = 4;
  BookingType bookingType = BookingType.own;
  String paymentMethod = "equally";

  final TextEditingController descriptionController = TextEditingController();
  final RewardService _rewardService = RewardService();

  List<UserVoucherModel> vouchers = [];
  UserVoucherModel? selectedVoucher;

  @override
  void initState() {
    super.initState();
    loadVoucher();
  }

  Future<void> loadVoucher() async {
    final data = await _rewardService.getUserVouchers();

    setState(() {
      vouchers = data.where((e) => e.status == "active").toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingViewModel = context.read<BookingViewModel>();
    double discount = bookingType == BookingType.own
        ? (selectedVoucher?.discount.toDouble() ?? 0)
        : 0;

    double total = widget.venue.pricePerHour - discount;

    if (total < 0) {
      total = 0;
    }

    if (total < 0) {
      total = 0;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Booking Confirmation")),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Venue",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.sports_soccer),
                  title: Text(widget.venue.name),
                  subtitle: Text(widget.venue.address),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Sport",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Text(widget.venue.sportType),

              const SizedBox(height: 20),

              const Text(
                "Booking Date",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Text(DateFormat('dd MMM yyyy').format(widget.bookingDate)),

              const SizedBox(height: 20),

              const Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),

              Text("${widget.startTime} - ${widget.endTime}"),
              const SizedBox(height: 20),

              const Text(
                "Booking Type",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              RadioListTile<BookingType>(
                value: BookingType.own,
                groupValue: bookingType,
                title: const Text("Personal Booking"),
                onChanged: (value) {
                  setState(() {
                    bookingType = value!;
                  });
                },
              ),

              RadioListTile<BookingType>(
                value: BookingType.match,
                groupValue: bookingType,
                title: const Text("Find Match"),
                subtitle: const Text(
                  "Create a public match for others to join.",
                ),
                onChanged: (value) {
                  setState(() {
                    bookingType = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // ====================== VOUCHER ======================
              if (bookingType == BookingType.own) ...[
                const Text(
                  "Available Vouchers",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<UserVoucherModel>(
                  isExpanded: true,
                  value: selectedVoucher,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text("No Voucher"),
                  items: vouchers.map((voucher) {
                    return DropdownMenuItem(
                      value: voucher,
                      child: Text("${voucher.title} (-RM${voucher.discount})"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVoucher = value;
                    });
                  },
                ),

                const SizedBox(height: 20),
              ],

              // ====================== MATCH SETTINGS ======================
              if (bookingType == BookingType.match) ...[
                const Text(
                  "Maximum Players",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<int>(
                  value: maximumPlayers,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(
                    9,
                    (index) => DropdownMenuItem(
                      value: index + 2,
                      child: Text("${index + 2} Players"),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      maximumPlayers = value!;
                    });
                  },
                ),

                const SizedBox(height: 20),

                PaymentMethodSelector(
                  paymentMethod: paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),
              ],

              const Text(
                "Price",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Text(
                "RM ${widget.venue.pricePerHour.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              if (selectedVoucher != null) ...[
                const SizedBox(height: 10),

                Text(
                  "Discount : -RM${selectedVoucher!.discount}",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const SizedBox(height: 10),

              Text(
                "Total : RM ${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => BookingSummaryDialog(
                        venueName: widget.venue.name,
                        date: DateFormat(
                          'dd MMM yyyy',
                        ).format(widget.bookingDate),
                        time: "${widget.startTime} - ${widget.endTime}",
                        price: widget.venue.pricePerHour,
                        discount: discount,
                        total: total,
                        voucher: selectedVoucher?.title,
                        onConfirm: () async {
                          Navigator.pop(context);

                          final uid = FirebaseAuth.instance.currentUser!.uid;

                          final userDoc = await FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .get();

                          final fullName =
                              userDoc.data()?["fullName"] ?? "Unknown User";

                          final bookingId = const Uuid().v4();

                          final booking = BookingModel(
                            id: bookingId,

                            venueId: widget.venue.id,
                            venueName: widget.venue.name,

                            vendorId: widget.venue.vendorId,

                            bookerId: uid,
                            bookerName: fullName,

                            sportType: widget.venue.sportType,

                            bookingType: bookingType == BookingType.match
                                ? "match"
                                : "own",

                            bookingDate: widget.bookingDate,

                            startTime: widget.startTime,
                            endTime: widget.endTime,

                            totalPrice: total,

                            status: "approved",
                            isReviewed: false,
                            rewardGiven: false,

                            revenueAdded: false,
                          );

                          if (selectedVoucher != null) {
                            await _rewardService.useVoucher(
                              selectedVoucher!.id,
                            );
                            await loadVoucher();
                            setState(() {
                              selectedVoucher = null;
                            });
                          }

                          final scheduleService = BookingScheduleService();

                          final schedule = await scheduleService.loadSchedule(
                            venueId: widget.venue.id,
                            date: widget.bookingDate,
                          );

                          // Tambah block ni
                          if (schedule == null) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Booking schedule not found."),
                              ),
                            );

                            return;
                          }

                          // Lepas tu baru try
                          try {
                            final slot = schedule.slots.firstWhere(
                              (e) =>
                                  e.startTime == widget.startTime &&
                                  e.endTime == widget.endTime,
                            );

                            await scheduleService.bookSlot(
                              schedule: schedule,
                              slotId: slot.id,
                            );

                            await bookingViewModel.createBooking(booking);

                            if (bookingType == BookingType.match) {
                              final match = MatchModel(
                                matchId: const Uuid().v4(),

                                bookingId: bookingId,

                                hostId: uid,
                                hostName: fullName,

                                participants: [
                                  {"userId": uid, "userName": fullName},
                                ],

                                maximumPlayers: maximumPlayers,
                                currentPlayers: 1,

                                paymentMethod: paymentMethod,

                                currentPricePerPerson: paymentMethod == "host"
                                    ? 0
                                    : total,

                                description: descriptionController.text.trim(),

                                status: "waiting",

                                createdAt: Timestamp.now(),
                              );

                              await context.read<MatchViewModel>().createMatch(
                                match,
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to create booking: $e"),
                              ),
                            );

                            return;
                          }

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                bookingType == BookingType.match
                                    ? "Match created successfully."
                                    : "Booking created successfully.",
                              ),
                            ),
                          );

                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      ),
                    );
                  },

                  child: Text(
                    bookingType == BookingType.match
                        ? "Create Match"
                        : "Confirm Booking",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
