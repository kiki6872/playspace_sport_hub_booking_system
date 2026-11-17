import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/dashboard/viewModels/dashboard_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/venue/views/venue_details_page.dart';

import 'package:playspace_sport_hub_booking_system/src/widgets/venue_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchText = "";
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    final venues = viewModel.searchVenues(searchText);

    return Scaffold(
      appBar: AppBar(title: const Text("Search Venue")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search by venue, sport or location...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchText.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();

                          setState(() {
                            searchText = "";
                          });
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : venues.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 70, color: Colors.grey),

                          SizedBox(height: 10),

                          Text(
                            "No venue found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            "Try another keyword.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: venues.length,
                      itemBuilder: (context, index) {
                        final venue = venues[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: VenueCard(
                            venueId: venue.id,
                            name: venue.name,
                            address: venue.address,
                            sportType: venue.sportType,
                            rating: venue.rating,
                            pricePerHour: venue.pricePerHour,
                            imageUrl: venue.imageUrl,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VenueDetailsPage(venue: venue),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
