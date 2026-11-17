import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/users/viewModels/users_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/users/views/user_details_page.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/users/viewModels/user_details_viewmodel.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<UsersViewModel>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UsersViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),

      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// Search Bar
                  TextField(
                    onChanged: (value) {
                      viewModel.searchUsers(value);
                    },

                    decoration: InputDecoration(
                      hintText: "Search users...",
                      prefixIcon: const Icon(Icons.search),

                      filled: true,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text("All"),
                          selected: false,
                          onSelected: (_) {
                            viewModel.filterUsers("All");
                          },
                        ),

                        const SizedBox(width: 10),

                        FilterChip(
                          label: const Text("Admin"),
                          selected: false,
                          onSelected: (_) {
                            viewModel.filterUsers("admin");
                          },
                        ),

                        const SizedBox(width: 10),

                        FilterChip(
                          label: const Text("Vendor"),
                          selected: false,
                          onSelected: (_) {
                            viewModel.filterUsers("vendor");
                          },
                        ),

                        const SizedBox(width: 10),

                        FilterChip(
                          label: const Text("Booker"),
                          selected: false,
                          onSelected: (_) {
                            viewModel.filterUsers("booker");
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Users List
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = viewModel.filteredUsers[index];

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.green.shade100,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.green,
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.fullName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            user.email,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Chip(label: Text(user.role.toUpperCase())),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ChangeNotifierProvider(
                                                create: (_) {
                                                  final vm =
                                                      UserDetailsViewModel();
                                                  vm.initialize(user);
                                                  return vm;
                                                },
                                                child: UserDetailsPage(
                                                  user: user,
                                                ),
                                              ),
                                        ),
                                      );

                                      if (result == true && context.mounted) {
                                        context
                                            .read<UsersViewModel>()
                                            .loadUsers();
                                      }
                                    },

                                    icon: const Icon(Icons.visibility),

                                    label: const Text("View Details"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
