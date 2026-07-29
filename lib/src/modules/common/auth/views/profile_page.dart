import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewModels/profile_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/dashboard/viewModels/dashboard_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/venue/services/image_upload_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final fullName = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final ImageUploadService _imageService = ImageUploadService();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final vm = context.read<ProfileViewModel>();

      await vm.loadProfile();

      fullName.text = vm.profile["fullName"] ?? "";
      email.text = vm.profile["email"] ?? "";
      phone.text = vm.profile["phone"] ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );

                      if (picked == null) return;

                      final url = await _imageService.uploadImage(
                        File(picked.path),
                      );

                      if (url == null) return;

                      await vm.updateProfileImage(url);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profile image updated.")),
                      );
                      await vm.updateProfileImage(url);
                    },
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage:
                          (vm.profile["profileImage"] ?? "")
                              .toString()
                              .isNotEmpty
                          ? NetworkImage(vm.profile["profileImage"])
                          : null,
                      child:
                          (vm.profile["profileImage"] ?? "").toString().isEmpty
                          ? const Icon(Icons.person, size: 45)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: fullName,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),

                  const SizedBox(height: 25),
                  TextField(
                    controller: email,
                    enabled: false,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await vm.save(
                          fullName: fullName.text,
                          phoneNumber: phone.text,
                        );
                        await context.read<ProfileViewModel>().loadProfile();

                        await context
                            .read<DashboardViewModel>()
                            .loadCurrentUser();

                        if (!mounted) return;

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profile updated.")),
                        );
                      },
                      child: const Text("Update"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
