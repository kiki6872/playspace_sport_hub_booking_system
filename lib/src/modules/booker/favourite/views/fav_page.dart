import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/booker/favourite/viewModels/fav_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/venue/views/venue_details_page.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<FavouriteViewModel>().loadFavouriteVenues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FavouriteViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Favourite")),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.venues.isEmpty
          ? const Center(child: Text("No favourite venues yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: vm.venues.length,
              itemBuilder: (context, index) {
                final venue = vm.venues[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: venue.imageUrl.isEmpty
                              ? Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image),
                                )
                              : Image.network(
                                  venue.imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),

                        const SizedBox(width: 16),

                        /// LEFT SIDE
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                venue.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                venue.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(venue.rating.toStringAsFixed(1)),
                                ],
                              ),

                              const SizedBox(height: 10),
                            ],
                          ),
                        ),

                        /// RIGHT SIDE
                        SizedBox(
                          height: 110,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () async {
                                  await vm.toggleFavourite(venue.id);
                                  await vm.loadFavouriteVenues();
                                },
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 28,
                                ),
                              ),

                              const Spacer(),

                              SizedBox(
                                width: 120,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            VenueDetailsPage(venue: venue),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Book Now",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
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
