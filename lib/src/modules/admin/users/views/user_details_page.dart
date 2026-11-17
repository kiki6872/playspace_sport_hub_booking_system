import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/users/viewModels/user_details_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/models/user_model.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/confirmation_dialog.dart';

class UserDetailsPage extends StatelessWidget {
  final UserModel user;

  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserDetailsViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 45,
                child: Icon(Icons.person, size: 45),
              ),
            ),

            const SizedBox(height: 30),

            _buildInfo("Full Name", user.fullName),

            const SizedBox(height: 18),

            _buildInfo("Email", user.email),

            const SizedBox(height: 18),

            const Text("Role", style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 6),

            DropdownButtonFormField<String>(
              value: viewModel.selectedRole,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: "admin", child: Text("Admin")),
                DropdownMenuItem(value: "vendor", child: Text("Vendor")),
                DropdownMenuItem(value: "booker", child: Text("Booker")),
              ],
              onChanged: (value) {
                if (value != null) {
                  viewModel.changeRole(value);
                }
              },
            ),

            const SizedBox(height: 18),

            _buildInfo("Status", viewModel.user.status),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                onPressed: () async {
                  await viewModel.saveRole();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Role updated successfully")),
                  );

                  Navigator.pop(context, true);
                },
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await viewModel.toggleUserStatus();
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        viewModel.user.status == "active"
                            ? "User activated"
                            : "User suspended",
                      ),
                    ),
                  );
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.block),
                label: Text(
                  viewModel.user.status == "active"
                      ? "Suspend User"
                      : "Activate User",
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      title: "Delete User",
                      message: "Are you sure you want to delete this user?",
                      onConfirm: () {
                        Navigator.pop(context, true);
                      },
                    ),
                  );

                  if (confirm != true) return;

                  await viewModel.deleteUser();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User deleted successfully")),
                  );

                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.delete),
                label: const Text("Delete User"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),

        const SizedBox(height: 6),

        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
