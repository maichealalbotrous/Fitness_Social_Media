import 'package:flutter/material.dart';
import 'package:fitness_social_app/features/coach/presentation/coach_controller.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/user/data/local_profile_storage.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/local_profile_controller.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';

class MyCoachesPage extends StatefulWidget {
  const MyCoachesPage({super.key, required this.controller});
  final CoachController controller;

  @override
  State<MyCoachesPage> createState() => _MyCoachesPageState();
}

class _MyCoachesPageState extends State<MyCoachesPage> {
  LocalProfileController? _profileController;

  @override
  void initState() {
    super.initState();
    _loadMyCoaches();
  }

  Future<void> _loadMyCoaches() async {
    final profileStorage = await LocalProfileStorage.create();
    final profileController = LocalProfileController(
      sessionStorage: SecureSessionStorage(),
      profileStorage: profileStorage,
    );
    await profileController.load();
    final participantId = profileController.userId;
    if (!mounted) {
      profileController.dispose();
      return;
    }
    setState(() => _profileController = profileController);
    if (participantId == null || participantId.isEmpty) {
      widget.controller.error = 'Unable to determine the current user.';
      widget.controller.notifyListeners();
      return;
    }
    await widget.controller.loadParticipantCoaches(participantId);
  }

  @override
  void dispose() {
    _profileController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coaches'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed(AppRoutes.feed);
            }
          },
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (_, __) {
          if (widget.controller.isLoading) return const Center(child: CircularProgressIndicator());
          if (widget.controller.error != null) return Center(child: Text(widget.controller.error!));
          final coaches = widget.controller.participantCoaches;
          if (coaches.isEmpty) return const Center(child: Text('You do not have any coaches yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: coaches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final coach = coaches[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: coach.profilePictureUrl == null || coach.profilePictureUrl!.isEmpty ? null : NetworkImage(coach.profilePictureUrl!),
                    child: coach.profilePictureUrl == null || coach.profilePictureUrl!.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(coach.username),
                  subtitle: Text('${coach.averageRating.toStringAsFixed(1)} / 5 • ${coach.totalParticipants} participants'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
