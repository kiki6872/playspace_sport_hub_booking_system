import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:playspace_sport_hub_booking_system/src/models/match_with_booking_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/match/viewModels/match_viewmodel.dart';

class MatchWithBookingCard extends StatelessWidget {
  final MatchWithBookingModel item;
  final bool isHost;

  const MatchWithBookingCard({
    super.key,
    required this.item,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    void _showParticipants(BuildContext context, dynamic match) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Participants",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                ...match.participants.map<Widget>((user) {
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Row(
                      children: [
                        Expanded(child: Text(user["userName"])),
                        if (user["userId"] == match.hostId)
                          const Chip(
                            label: Text("HOST", style: TextStyle(fontSize: 10)),
                          ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 10),

                Text(
                  "${match.currentPlayers}/${match.maximumPlayers} Players Joined",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),
              ],
            ),
          );
        },
      );
    }

    final match = item.match;
    final booking = item.booking;

    final pricePerPerson = match.paymentMethod == "host"
        ? 0
        : match.currentPricePerPerson;

    final currentUserId = context.read<MatchViewModel>().currentUserId;

    final hasJoined = match.participants.any(
      (e) => e["userId"] == currentUserId,
    );
    final isFull = match.currentPlayers >= match.maximumPlayers;
    Color chipColor;

    switch (match.status) {
      case "waiting":
        chipColor = Colors.orange;
        break;

      case "ready":
        chipColor = Colors.blue;
        break;

      case "full":
        chipColor = Colors.red;
        break;

      case "completed":
        chipColor = Colors.green;
        break;

      default:
        chipColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showParticipants(context, match);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.sportType,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    "Hosted by ${match.hostName}",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 5),
                  Expanded(child: Text(booking.venueName)),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 5),
                  Text(DateFormat("dd MMM yyyy").format(booking.bookingDate)),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.access_time, size: 18),
                  const SizedBox(width: 5),
                  Text("${booking.startTime} - ${booking.endTime}"),
                ],
              ),

              const Divider(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Players", style: TextStyle(color: Colors.grey[700])),
                  Text(
                    "${match.currentPlayers}/${match.maximumPlayers}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Payment", style: TextStyle(color: Colors.grey[700])),
                  Text(
                    match.paymentMethod == "host"
                        ? "Host Pays"
                        : "Split Equally",
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Price / Person",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    match.paymentMethod == "host"
                        ? "FREE"
                        : "RM ${pricePerPerson.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Status", style: TextStyle(color: Colors.grey[700])),
                  Chip(
                    backgroundColor: chipColor.withOpacity(0.15),
                    side: BorderSide(color: chipColor),
                    label: Text(
                      match.status.toUpperCase(),
                      style: TextStyle(
                        color: chipColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              if (match.description.isNotEmpty) ...[
                const SizedBox(height: 15),

                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(match.description),
              ],

              const SizedBox(height: 20),

              if (isHost) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: match.status == "completed"
                        ? null
                        : () async {
                            await context.read<MatchViewModel>().closeMatch(
                              match.matchId,
                            );
                          },
                    child: const Text("Complete Match"),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Match"),
                          content: const Text(
                            "Are you sure you want to delete this match?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await context.read<MatchViewModel>().deleteMatch(
                          match.matchId,
                        );
                      }
                    },
                    child: const Text("Delete Match"),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isFull && !hasJoined
                        ? null
                        : () async {
                            final vm = context.read<MatchViewModel>();

                            if (hasJoined) {
                              await vm.leaveMatch(match);
                            } else {
                              await vm.joinMatch(match);
                            }
                          },
                    child: Text(
                      hasJoined
                          ? "Leave Match"
                          : isFull
                          ? "Match Full"
                          : "Join Match",
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
