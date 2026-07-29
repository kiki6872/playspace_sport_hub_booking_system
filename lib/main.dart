import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/vendor/promotion/viewModels/promotion_viewmodel.dart';
import 'firebase_options.dart';
import 'src/core/theme/app_theme.dart';
import 'src/routes/app_router.dart';

import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/profile_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/common/auth/viewModels/login_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/search/viewModels/search_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/booking/viewModels/booking_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/review/viewModels/review_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/reward/viewModels/reward_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/admin/reports/viewModels/reports_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/match/viewModels/match_viewmodel.dart';
import 'package:playspace_sport_hub_booking_system/src/modules/booker/favourite/viewModels/fav_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),

        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => BookingViewModel()),

        ChangeNotifierProvider(create: (_) => ReviewViewModel()),
        ChangeNotifierProvider(create: (_) => RewardViewModel()),
        ChangeNotifierProvider(create: (_) => ReportsViewModel()),
        ChangeNotifierProvider(create: (_) => MatchViewModel()),
        ChangeNotifierProvider(create: (_) => FavouriteViewModel()),
        ChangeNotifierProvider(create: (_) => PromotionViewModel()),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel()..loadProfile(),
        ),
      ],
      child: const PlaySpaceApp(),
    ),
  );
}

class PlaySpaceApp extends StatelessWidget {
  const PlaySpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PlaySpace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
