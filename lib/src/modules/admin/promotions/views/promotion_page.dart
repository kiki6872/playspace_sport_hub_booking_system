import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/models/promotion_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/promotions/viewModels/promotion_viewmodel.dart';
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

    Future.microtask(() {
      context.read<PromotionViewModel>().loadPromotions();
    });
  }

  Future<void> _showPromotionConfirmation(
    BuildContext context,
    PromotionViewModel vm,
    String id,
    bool approve,
  ) async {
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: approve ? "Approve Promotion" : "Reject Promotion",

        message: approve
            ? "Are you sure you want to approve this promotion?"
            : "Are you sure you want to reject this promotion?",

        confirmButtonText: approve ? "Approve" : "Reject",

        confirmButtonColor: approve ? const Color(0xFFC8F528) : Colors.red,

        onConfirm: () async {
          Navigator.pop(context);

          if (approve) {
            await vm.approve(id);
          } else {
            await vm.reject(id);
          }

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                approve
                    ? "Promotion approved successfully."
                    : "Promotion rejected.",
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PromotionViewModel>();

    return DefaultTabController(
      length: 4,

      child: Scaffold(
        appBar: AppBar(
          title: const Text("Promotion Approval"),

          bottom: const TabBar(
            indicatorColor: Colors.green,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Active"),
              Tab(text: "Completed"),
              Tab(text: "Rejected"),
            ],
          ),
        ),

        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildPromotionList(
                    vm.pendingPromotions,
                    vm,
                    showActionButton: true,
                  ),

                  _buildPromotionList(
                    vm.activePromotions,
                    vm,
                    showActionButton: false,
                    statusText: "ACTIVE",
                    statusColor: Colors.green,
                  ),

                  _buildPromotionList(
                    vm.completedPromotions,
                    vm,
                    showActionButton: false,
                    statusText: "COMPLETED",
                    statusColor: Colors.blue,
                  ),

                  _buildPromotionList(
                    vm.rejectedPromotions,
                    vm,
                    showActionButton: false,
                    statusText: "REJECTED",
                    statusColor: Colors.red,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPromotionList(
    List<PromotionModel> promotions,
    PromotionViewModel vm, {
    required bool showActionButton,
    String? statusText,
    Color? statusColor,
  }) {
    if (promotions.isEmpty) {
      return const Center(
        child: Text("No promotions found.", style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: promotions.length,
      itemBuilder: (context, index) {
        return _buildPromotionCard(
          promotions[index],
          vm,
          showActionButton: showActionButton,
          statusText: statusText,
          statusColor: statusColor,
        );
      },
    );
  }

  Widget _buildPromotionCard(
    PromotionModel promotion,
    PromotionViewModel vm, {
    required bool showActionButton,
    String? statusText,
    Color? statusColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Promotion Title
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

            const SizedBox(height: 14),

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

            const SizedBox(height: 14),

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

            const SizedBox(height: 18),

            if (showActionButton)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC8F528),
                        foregroundColor: Colors.black,
                      ),

                      icon: const Icon(Icons.check),

                      label: const Text("Approve"),

                      onPressed: () {
                        _showPromotionConfirmation(
                          context,
                          vm,
                          promotion.id,
                          true,
                        );
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

                      icon: const Icon(Icons.close),

                      label: const Text("Reject"),

                      onPressed: () {
                        _showPromotionConfirmation(
                          context,
                          vm,
                          promotion.id,
                          false,
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
