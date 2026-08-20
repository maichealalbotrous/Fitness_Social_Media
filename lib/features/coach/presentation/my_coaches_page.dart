import 'package:flutter/material.dart';
import 'package:fitness_social_app/features/coach/presentation/coach_controller.dart';

class MyCoachesPage extends StatefulWidget {
  const MyCoachesPage({super.key, required this.controller});
  final CoachController controller;

  @override
  State<MyCoachesPage> createState() => _MyCoachesPageState();
}

class _MyCoachesPageState extends State<MyCoachesPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadMyCoaches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coaches'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
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
