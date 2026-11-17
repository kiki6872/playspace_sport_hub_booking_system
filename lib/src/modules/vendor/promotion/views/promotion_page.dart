import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:playspace_sport_hub_booking_system/src/models/promotion_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/promotion/viewModels/promotion_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/promotion/views/create_promotion_page.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/confirmation_dialog.dart';

class PromotionPage extends StatefulWidget {
  const PromotionPage({super.key});

  @override
  State<PromotionPage> createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final vm = context.read<PromotionViewModel>();

      await vm.loadPromotions();
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PromotionViewModel>();

    return DefaultTabController(
      length: 4,

      child: Scaffold(
        appBar: AppBar(
          title: const Text("Promotions"),

          bottom: const TabBar(
            indicatorColor: Colors.green,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Approved"),
              Tab(text: "Completed"),
              Tab(text: "Rejected"),
            ],
          ),
        ),

        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  buildPromotionList("pending"),
                  buildApprovedPromotionList(),
                  buildCompletedPromotionList(),
                  buildPromotionList("rejected"),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.green,

          icon: const Icon(Icons.add),

          label: const Text("Add Promotion"),

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreatePromotionPage()),
            ).then((_) {
              context.read<PromotionViewModel>().loadPromotions();
            });
          },
        ),
      ),
    );
  }

  Widget buildPromotionList(String status) {
    final vm = context.watch<PromotionViewModel>();

    final promotions = vm.promotions.where((e) => e.status == status).toList();

    if (promotions.isEmpty) {
      return Center(
        child: Text(
          "No ${status[0].toUpperCase()}${status.substring(1)} Promotions.",
          style: const TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: promotions.length,
      itemBuilder: (context, index) {
        return buildPromotionCard(promotions[index], tabType: status);
      },
    );
  }

  Widget buildApprovedPromotionList() {
    final vm = context.watch<PromotionViewModel>();

    final promotions = vm.promotions.where((e) {
      return e.status == "approved" && e.endDate.isAfter(DateTime.now());
    }).toList();

    if (promotions.isEmpty) {
      return const Center(child: Text("No Approved Promotions."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: promotions.length,
      itemBuilder: (_, index) {
        return buildPromotionCard(promotions[index], tabType: "approved");
      },
    );
  }

  Widget buildCompletedPromotionList() {
    final vm = context.watch<PromotionViewModel>();

    final promotions = vm.promotions.where((promotion) {
      return promotion.status == "approved" &&
          promotion.endDate.isBefore(DateTime.now());
    }).toList();

    if (promotions.isEmpty) {
      return const Center(child: Text("No Completed Promotions."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: promotions.length,
      itemBuilder: (context, index) {
        return buildPromotionCard(promotions[index], tabType: "completed");
      },
    );
  }

  Future<void> _acceptRejection(PromotionModel promotion) async {
    await showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: "Accept Rejection",
        message:
            "This promotion will remain rejected and stay in this list. Continue?",
        confirmButtonText: "Accept",
        cancelButtonText: "Cancel",
        onConfirm: () {
          Navigator.pop(context);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Rejection accepted.")));
        },
      ),
    );
  }

  Future<void> _reapplyPromotion(
    PromotionViewModel vm,
    PromotionModel promotion,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: "Re-apply Promotion",
        message:
            "This will send the promotion back for admin review as a new pending request. Continue?",
        confirmButtonText: "Re-apply",
        onConfirm: () async {
          Navigator.pop(context);

          await vm.reapplyPromotion(promotion.id);

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Promotion re-applied for review.")),
          );
        },
      ),
    );
  }

  Widget buildPromotionCard(
    PromotionModel promotion, {
    required String tabType,
  }) {
    final vm = context.read<PromotionViewModel>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              promotion.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            /// Description
            const Text(
              "Description:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),

            const SizedBox(height: 6),

            Text(
              promotion.description,
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),

            const SizedBox(height: 12),

            /// Date
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 18, color: Colors.grey),

                const SizedBox(width: 6),

                Text(
                  "${DateFormat("dd MMM yyyy").format(promotion.startDate)}"
                  " - "
                  "${DateFormat("dd MMM yyyy").format(promotion.endDate)}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Discount + Apply To
            Row(
              children: [
                Chip(
                  backgroundColor: Colors.green.shade100,
                  label: Text(
                    "${promotion.discountPercentage.toStringAsFixed(0)}% OFF",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Chip(
                  backgroundColor: Colors.blue.shade100,
                  label: Text(
                    promotion.applyTo == "all"
                        ? "All Venues"
                        : "Selected Venues",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (tabType == "pending") ...[
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CreatePromotionPage(promotion: promotion),
                          ),
                        ).then((_) {
                          vm.loadPromotions();
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete"),
                      onPressed: () async {
                        await showDialog(
                          context: context,

                          builder: (_) => ConfirmationDialog(
                            title: "Delete Promotion",

                            message:
                                "Are you sure you want to delete this promotion?",

                            confirmButtonText: "Delete",

                            cancelButtonText: "Cancel",

                            onConfirm: () async {
                              Navigator.pop(context);

                              await vm.deletePromotion(promotion.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],

            if (tabType == "completed") ...[
              const SizedBox(height: 15),

              Row(
                children: [
                  const Icon(Icons.confirmation_number, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Used ${vm.usageCounts[promotion.id] ?? 0} time(s)",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],

            if (tabType == "rejected") ...[
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _acceptRejection(promotion),
                      child: const Text("Accept Rejection"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _reapplyPromotion(vm, promotion),
                      child: const Text("Re-apply"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
