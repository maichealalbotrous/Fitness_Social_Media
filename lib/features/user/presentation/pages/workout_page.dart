import 'package:fitness_social_app/features/user/presentation/components/workout/log_pr_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/log_workout_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/performance_header.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/progression_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/training_consistency_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/volume_intensity_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/workout_app_drawer.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/workout_mobile_navigation.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/workout_theme.dart';
import 'package:flutter/material.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorkoutTheme.background,
      drawer: const WorkoutAppDrawer(),
      bottomNavigationBar: const WorkoutMobileNavigation(),
      body: SafeArea(
        child: Scrollbar(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: WorkoutTheme.background,
                surfaceTintColor: Colors.transparent,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                title: const _WorkoutLogo(),
                centerTitle: false,
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(18, 18, 18, 120),
                sliver: SliverToBoxAdapter(child: _WorkoutContent()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutContent extends StatelessWidget {
  const _WorkoutContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PerformanceHeader(),
        SizedBox(height: 22),
        TrainingConsistencyCard(),
        SizedBox(height: 18),
        VolumeIntensityCard(),
        SizedBox(height: 18),
        MuscleFrequencyCard(),
        SizedBox(height: 18),
        LogWorkoutCard(),
        SizedBox(height: 18),
        LogPrCard(),
        SizedBox(height: 18),
        ProgressionCard(),
      ],
    );
  }
}

class _WorkoutLogo extends StatelessWidget {
  const _WorkoutLogo();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'REP',
            style: TextStyle(
              color: WorkoutTheme.lime,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: 'FLOW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
