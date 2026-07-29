import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/admin/reports/viewModels/reports_viewmodel.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ReportsViewModel>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportsViewModel>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Analytics Dashboard"),

          bottom: const TabBar(
            isScrollable: false,

            tabs: [
              Tab(text: "Booking"),
              Tab(text: "Sports"),
              Tab(text: "Peak Usage"),
            ],
          ),
        ),

        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),

                    child: GridView.count(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      crossAxisCount: 2,

                      crossAxisSpacing: 12,

                      mainAxisSpacing: 12,

                      childAspectRatio: 1.45,

                      children: [
                        _buildSummaryCard(
                          title: "Active Users",
                          value: vm.totalUsers.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                        ),

                        _buildSummaryCard(
                          title: "Registered Venues",
                          value: vm.totalVenues.toString(),
                          icon: Icons.sports_soccer,
                          color: Colors.orange,
                        ),

                        _buildSummaryCard(
                          title: "Total Bookings",
                          value: vm.totalBookings.toString(),
                          icon: Icons.event_available,
                          color: Colors.green,
                        ),

                        _buildSummaryCard(
                          title: "Revenue",
                          value: "RM ${vm.totalRevenue.toStringAsFixed(2)}",
                          icon: Icons.attach_money,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildBookingOverview(vm.bookingOverview),

                        _buildPopularSports(vm.popularSports),

                        _buildPeakUsage(vm.peakUsage),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            CircleAvatar(
              radius: 24,

              backgroundColor: color.withOpacity(0.15),

              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    value,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  Widget _buildBookingOverview(Map<String, int> data) {
    if (data.isEmpty) {
      return const Center(child: Text("No booking data."));
    }

    final total = data.values.fold(0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: data.entries.map((entry) {
        final percent = total == 0 ? 0.0 : entry.value / total;

        return Card(
          margin: const EdgeInsets.only(bottom: 14),

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Text(
                      entry.value.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                LinearProgressIndicator(
                  value: percent,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPopularSports(Map<String, int> data) {
    if (data.isEmpty) {
      return const Center(child: Text("No sports data."));
    }

    final max = data.values.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: data.entries.map((entry) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.sports_soccer),

            title: Text(entry.key),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(value: entry.value / max),
            ),

            trailing: Text(
              entry.value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPeakUsage(Map<String, int> data) {
    if (data.isEmpty) {
      return const Center(child: Text("No peak usage."));
    }

    return ListView(
      padding: const EdgeInsets.all(16),

      children: data.entries.map((entry) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.access_time),

            title: Text(entry.key),

            trailing: Chip(label: Text("${entry.value} Bookings")),
          ),
        );
      }).toList(),
    );
  }
}
