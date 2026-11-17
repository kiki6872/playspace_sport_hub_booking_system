import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:playspace_sport_hub_booking_system/src/models/promotion_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/promotion/viewModels/promotion_viewmodel.dart';

class CreatePromotionPage extends StatefulWidget {
  final PromotionModel? promotion;

  const CreatePromotionPage({super.key, this.promotion});

  @override
  State<CreatePromotionPage> createState() => _CreatePromotionPageState();
}

class _CreatePromotionPageState extends State<CreatePromotionPage> {
  final titleController = TextEditingController();

  final descriptionController = TextEditingController();

  final discountController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  String applyTo = "all";

  List<String> selectedVenueIds = [];

  @override
  void initState() {
    super.initState();

    final promotion = widget.promotion;

    if (promotion != null) {
      titleController.text = promotion.title;

      descriptionController.text = promotion.description;

      discountController.text = promotion.discountPercentage.toString();

      startDate = promotion.startDate;

      endDate = promotion.endDate;

      applyTo = promotion.applyTo;

      selectedVenueIds = List<String>.from(promotion.venueIds);
    }

    Future.microtask(() {
      context.read<PromotionViewModel>().loadVendorVenues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PromotionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.promotion == null ? "Create Promotion" : "Edit Promotion",
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Promotion Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Discount (%)",
                border: OutlineInputBorder(),
                suffixText: "%",
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Promotion Period",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                startDate == null
                    ? "Select Start Date"
                    : DateFormat("dd MMM yyyy").format(startDate!),
              ),
              leading: const Icon(Icons.calendar_month),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  setState(() {
                    startDate = picked;
                  });
                }
              },
            ),

            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                endDate == null
                    ? "Select End Date"
                    : DateFormat("dd MMM yyyy").format(endDate!),
              ),
              leading: const Icon(Icons.event),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now(),
                  firstDate: startDate ?? DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  setState(() {
                    endDate = picked;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 15),

            const Text(
              "Apply Promotion To",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            RadioListTile<String>(
              value: "all",
              groupValue: applyTo,
              title: const Text("All Venues"),
              onChanged: (value) {
                setState(() {
                  applyTo = value!;
                  selectedVenueIds.clear();
                });
              },
            ),

            RadioListTile<String>(
              value: "selected",
              groupValue: applyTo,
              title: const Text("Selected Venues"),
              onChanged: (value) {
                setState(() {
                  applyTo = value!;
                });
              },
            ),

            if (applyTo == "selected") ...[
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Choose Venues",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 260,

                      child: ListView.builder(
                        itemCount: vm.vendorVenues.length,

                        itemBuilder: (context, index) {
                          final venue = vm.vendorVenues[index];

                          final selected = selectedVenueIds.contains(venue.id);

                          return CheckboxListTile(
                            value: selected,

                            controlAffinity: ListTileControlAffinity.leading,

                            title: Text(venue.name),

                            subtitle: Text(venue.sportType),

                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  if (!selectedVenueIds.contains(venue.id)) {
                                    selectedVenueIds.add(venue.id);
                                  }
                                } else {
                                  selectedVenueIds.remove(venue.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),

                icon: Icon(widget.promotion == null ? Icons.add : Icons.save),

                label: Text(
                  widget.promotion == null
                      ? "Create Promotion"
                      : "Update Promotion",
                ),

                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      discountController.text.isEmpty ||
                      startDate == null ||
                      endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please complete all fields."),
                      ),
                    );

                    return;
                  }

                  if (applyTo == "selected" && selectedVenueIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select at least one venue."),
                      ),
                    );

                    return;
                  }

                  final promotion = PromotionModel(
                    id: widget.promotion?.id ?? const Uuid().v4(),

                    vendorId: widget.promotion?.vendorId ?? "",

                    title: titleController.text,

                    description: descriptionController.text,

                    discountPercentage: double.parse(discountController.text),

                    startDate: startDate!,

                    endDate: endDate!,

                    isActive: widget.promotion?.isActive ?? false,

                    status: widget.promotion?.status ?? "pending",

                    applyTo: applyTo,

                    venueIds: selectedVenueIds,
                  );

                  if (widget.promotion == null) {
                    await context.read<PromotionViewModel>().createPromotion(
                      promotion,
                    );
                  } else {
                    await context.read<PromotionViewModel>().updatePromotion(
                      promotion,
                    );
                  }

                  if (!mounted) return;

                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
