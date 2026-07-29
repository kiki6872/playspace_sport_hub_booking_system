import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/booker/match/viewModels/match_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/widgets/match_with_booking_card.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchViewModel>().loadMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MatchViewModel>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Find Match"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Available"),
              Tab(text: "My Matches"),
            ],
          ),
        ),

        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(children: [_available(vm), _my(vm)]),
      ),
    );
  }

  Widget _available(MatchViewModel vm) {
    if (vm.availableMatches.isEmpty) {
      return const Center(child: Text("No available matches."));
    }

    return RefreshIndicator(
      onRefresh: vm.loadMatches,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vm.availableMatches.length,
        itemBuilder: (_, index) {
          return MatchWithBookingCard(
            item: vm.availableMatches[index],
            isHost: false,
          );
        },
      ),
    );
  }

  Widget _my(MatchViewModel vm) {
    if (vm.myMatches.isEmpty) {
      return const Center(child: Text("You haven't created any matches."));
    }

    return RefreshIndicator(
      onRefresh: vm.loadMatches,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vm.myMatches.length,
        itemBuilder: (_, index) {
          return MatchWithBookingCard(item: vm.myMatches[index], isHost: true);
        },
      ),
    );
  }
}
