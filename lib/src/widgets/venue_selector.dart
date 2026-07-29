import 'package:flutter/material.dart';
import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';

class VenueSelector extends StatelessWidget {
  final List<VenueModel> venues;
  final VenueModel? selectedVenue;
  final ValueChanged<VenueModel?> onChanged;

  const VenueSelector({
    super.key,
    required this.venues,
    required this.selectedVenue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<VenueModel>(
      isExpanded: true,
      value: selectedVenue,
      decoration: InputDecoration(
        labelText: "Venue",
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: venues.map((venue) {
        return DropdownMenuItem<VenueModel>(
          value: venue,
          child: Text(venue.name, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return "Please select a venue";
        }
        return null;
      },
    );
  }
}
