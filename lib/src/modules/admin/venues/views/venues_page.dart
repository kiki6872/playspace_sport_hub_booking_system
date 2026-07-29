import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/venues/viewModels/admin_venue_viewmodel.dart';

class VenuesPage extends StatefulWidget {
  const VenuesPage({super.key});

  @override
  State<VenuesPage> createState() => _VenuesPageState();
}

class _VenuesPageState extends State<VenuesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminVenueViewModel>().loadVenues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminVenueViewModel>();

    return DefaultTabController(
      length: 3,

      child: Scaffold(
        appBar: AppBar(
          title: const Text("Manage Venues"),

          bottom: TabBar(
            indicatorColor: Colors.limeAccent,
            labelColor: Colors.limeAccent,
            unselectedLabelColor: Colors.grey,

            tabs: [
              Tab(
                text:
                    "Pending (${vm.venues.where((e) => e.status == "pending").length})",
              ),

              Tab(
                text:
                    "Approved (${vm.venues.where((e) => e.status == "approved").length})",
              ),

              Tab(
                text:
                    "Rejected (${vm.venues.where((e) => e.status == "rejected").length})",
              ),
            ],
          ),
        ),

        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  buildVenueList("pending"),

                  buildVenueList("approved"),

                  buildVenueList("rejected"),
                ],
              ),
      ),
    );
  }

  Future<void> openGoogleMaps(String address) async {
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget buildVenueList(String status) {
    final vm = context.watch<AdminVenueViewModel>();

    final venues = vm.venues.where((e) => e.status == status).toList();

    if (venues.isEmpty) {
      return Center(
        child: Text(
          "No ${status.toUpperCase()} venues.",
          style: const TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),

      itemCount: venues.length,

      itemBuilder: (context, index) {
        return buildVenueCard(venues[index]);
      },
    );
  }

  Widget buildVenueCard(VenueModel venue) {
    final vm = context.read<AdminVenueViewModel>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: venue.imageUrl.isNotEmpty
                  ? Image.network(
                      venue.imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.image, size: 60, color: Colors.grey),
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            Text(
              venue.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const SizedBox(height: 8),

            Text(venue.sportType),

            const SizedBox(height: 8),

            Text(
              "RM ${venue.pricePerHour}/hour",

              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text("Open in Google Maps"),
                onPressed: () {
                  openGoogleMaps(venue.address);
                },
              ),
            ),
            const SizedBox(height: 12),
            if (venue.status == "pending")
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),

                      onPressed: () async {
                        await vm.approveVenue(venue.id);

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Venue approved.")),
                        );
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

                      onPressed: () async {
                        await vm.rejectVenue(venue.id);

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Venue rejected.")),
                        );
                      },

                      child: const Text("Reject"),
                    ),
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      venue.status == "approved" ? Icons.check : Icons.close,
                      color: venue.status == "approved"
                          ? Colors.green
                          : Colors.red,
                      size: 18,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      venue.status == "approved"
                          ? "Venue Approved"
                          : "Venue Rejected",
                      style: TextStyle(
                        color: venue.status == "approved"
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
