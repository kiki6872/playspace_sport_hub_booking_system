import 'package:flutter/material.dart';

class PlayerSelector extends StatelessWidget {
  final int minimumPlayers;
  final int maximumPlayers;
  final ValueChanged<int> onMinimumChanged;
  final ValueChanged<int> onMaximumChanged;

  const PlayerSelector({
    super.key,
    required this.minimumPlayers,
    required this.maximumPlayers,
    required this.onMinimumChanged,
    required this.onMaximumChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Players",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        _buildCounter(
          title: "Required Players",
          value: minimumPlayers,
          min: 2,
          max: maximumPlayers,
          onChanged: onMinimumChanged,
        ),

        const SizedBox(height: 20),

        _buildCounter(
          title: "Maximum Players",
          value: maximumPlayers,
          min: minimumPlayers,
          max: 20,
          onChanged: onMaximumChanged,
        ),
      ],
    );
  }

  Widget _buildCounter({
    required String title,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

        const SizedBox(height: 10),

        Row(
          children: [
            IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),

            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            IconButton(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }
}
