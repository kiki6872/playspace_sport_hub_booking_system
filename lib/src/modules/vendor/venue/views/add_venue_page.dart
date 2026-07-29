import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/vendor/venue/services/image_upload_service.dart';
import 'package:playspace_sport_hub_booking_system/src/models/venue_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/venue/viewModels/venue_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/custom_button.dart';

class AddVenuePage extends StatefulWidget {
  final VenueModel? venue;
  const AddVenuePage({super.key, this.venue});

  @override
  State<AddVenuePage> createState() => _AddVenuePageState();
}

class _AddVenuePageState extends State<AddVenuePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  final ImageUploadService _imageService = ImageUploadService();

  String _sportType = "Badminton";
  String _imageUrl = "";
  @override
  void initState() {
    super.initState();

    if (widget.venue != null) {
      _nameController.text = widget.venue!.name;
      _addressController.text = widget.venue!.address;
      _priceController.text = widget.venue!.pricePerHour.toString();
      _descriptionController.text = widget.venue!.description;

      _sportType = widget.venue!.sportType;
      _imageUrl = widget.venue?.imageUrl ?? "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitVenue() async {
    if (!_formKey.currentState!.validate()) return;

    final venue = VenueModel(
      id:
          widget.venue?.id ??
          FirebaseFirestore.instance.collection("venues").doc().id,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      sportType: _sportType,
      pricePerHour: double.parse(_priceController.text.trim()),
      rating: widget.venue?.rating ?? 0,
      imageUrl: _imageUrl,
      vendorId: FirebaseAuth.instance.currentUser!.uid,
      description: _descriptionController.text.trim(),
      status: widget.venue?.status ?? "pending",
    );

    if (widget.venue == null) {
      await context.read<VenueViewModel>().addVenue(venue);
    } else {
      await context.read<VenueViewModel>().updateVenue(venue);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.venue == null
              ? "Venue added successfully."
              : "Venue updated successfully.",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.venue == null ? "Add Venue" : "Edit Venue"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Venue Name"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Address"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _sportType,
                decoration: const InputDecoration(labelText: "Sport Type"),
                items: const [
                  DropdownMenuItem(
                    value: "Badminton",
                    child: Text("Badminton"),
                  ),
                  DropdownMenuItem(value: "Football", child: Text("Football")),
                  DropdownMenuItem(
                    value: "Basketball",
                    child: Text("Basketball"),
                  ),
                  DropdownMenuItem(value: "Futsal", child: Text("Futsal")),
                  DropdownMenuItem(value: "Tennis", child: Text("Tennis")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sportType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price Per Hour"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () async {
                  await _pickImage();

                  if (_selectedImage == null) return;

                  final url = await _imageService.uploadImage(_selectedImage!);

                  if (url == null) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to upload image.")),
                    );
                    return;
                  }

                  setState(() {
                    _imageUrl = url;
                  });
                },
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _imageUrl.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 45),
                              SizedBox(height: 10),
                              Text("Tap to Upload Venue Image"),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              CustomButton(text: "Submit Venue", onPressed: _submitVenue),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
    });
  }
}
