import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/vendor/venue/viewModels/venue_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/venue/views/add_venue_page.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/confirmation_dialog.dart';

class VendorVenuePage extends StatefulWidget {
  const VendorVenuePage({super.key});

  @override
  State<VendorVenuePage> createState() => _VendorVenuePageState();
}

class _VendorVenuePageState extends State<VendorVenuePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<VenueViewModel>().loadVenues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VenueViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("My Venues")),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: context.read<VenueViewModel>(),
                child: const AddVenuePage(),
              ),
            ),
          ).then((_) {
            context.read<VenueViewModel>().loadVenues();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Venue"),
      ),

      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.venues.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No venues found",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap 'Add Venue' to create one.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.venues.length,
              itemBuilder: (context, index) {
                final venue = viewModel.venues[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Placeholder
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: venue.imageUrl.isEmpty
                              ? Container(
                                  height: 170,
                                  width: double.infinity,
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : Image.network(
                                  venue.imageUrl,
                                  height: 170,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  key: ValueKey(venue.imageUrl),
                                ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          venue.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text(venue.address)),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.sports_soccer, size: 18),
                            const SizedBox(width: 6),
                            Text(venue.sportType),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.attach_money, size: 18),
                            const SizedBox(width: 6),
                            Text("RM ${venue.pricePerHour}/hour"),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: venue.status == "approved"
                                ? Colors.green
                                : venue.status == "pending"
                                ? Colors.orange
                                : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                venue.status == "approved"
                                    ? Icons.check_circle
                                    : venue.status == "pending"
                                    ? Icons.schedule
                                    : Icons.cancel,
                                color: Colors.white,
                                size: 16,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                venue.status[0].toUpperCase() +
                                    venue.status.substring(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ChangeNotifierProvider.value(
                                            value: context
                                                .read<VenueViewModel>(),
                                            child: AddVenuePage(venue: venue),
                                          ),
                                    ),
                                  ).then((_) {
                                    context.read<VenueViewModel>().loadVenues();
                                  });
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text("Edit"),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => ConfirmationDialog(
                                      title: "Delete Venue",
                                      message:
                                          "Are you sure you want to delete this venue?",
                                      confirmButtonText: "Delete",
                                      onConfirm: () {
                                        Navigator.pop(context, true);
                                      },
                                    ),
                                  );

                                  if (confirm != true) return;

                                  await viewModel.deleteVenue(venue.id);

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Venue deleted successfully.",
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text("Delete"),
                              ),
                            ),
                          ],
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
