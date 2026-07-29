import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playspace_sport_hub_booking_system/src/models/match_with_booking_model.dart';

import 'package:playspace_sport_hub_booking_system/src/models/match_model.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/match/services/match_service.dart';

class MatchViewModel extends ChangeNotifier {
  final MatchService _service = MatchService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String get currentUserId => _auth.currentUser!.uid;

  List<MatchWithBookingModel> _availableMatches = [];

  List<MatchWithBookingModel> get availableMatches => _availableMatches;

  List<MatchWithBookingModel> _myMatches = [];

  List<MatchWithBookingModel> get myMatches => _myMatches;

  Future<void> loadMatches() async {
    _isLoading = true;

    notifyListeners();

    try {
      _availableMatches = await _service.getOpenMatches();

      _myMatches = await _service.getMyMatches();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> createMatch(MatchModel match) async {
    await _service.createMatch(match);

    await loadMatches();
  }

  Future<void> joinMatch(MatchModel match) async {
    await _service.joinMatch(match);

    await loadMatches();
  }

  Future<void> leaveMatch(MatchModel match) async {
    await _service.leaveMatch(match);

    await loadMatches();
  }

  Future<void> deleteMatch(String id) async {
    await _service.deleteMatch(id);

    await loadMatches();
  }

  Future<void> closeMatch(String id) async {
    await _service.closeMatch(id);

    await loadMatches();
  }
}
