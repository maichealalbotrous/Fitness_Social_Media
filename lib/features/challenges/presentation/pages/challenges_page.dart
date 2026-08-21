import 'package:flutter/material.dart';

import '../../domain/entities/challenge.dart';
import '../challenges_dependencies.dart';
import '../controllers/challenges_controller.dart';
import 'challenge_details_page.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';
import 'create_challenge_page.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> with SingleTickerProviderStateMixin {
  late final ChallengesController _controller;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _controller = ChallengesDependencies.createController()..loadJoinable();
    _tabs = TabController(length: 2, vsync: this);
    _controller.loadMyChallenges();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      _controller.loadJoinable(),
      _controller.loadMyChallenges(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF030403),
          appBar: AppBar(
            backgroundColor: const Color(0xFF030403),
            foregroundColor: Colors.white,
            title: const Text('Challenges', style: TextStyle(fontWeight: FontWeight.w900)),
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
            actions: [
              IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
              IconButton(
                tooltip: 'Create challenge',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateChallengePage())),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
            bottom: TabBar(
              controller: _tabs,
              labelColor: const Color(0xFFDFFF00),
              unselectedLabelColor: Colors.white54,
              indicatorColor: const Color(0xFFDFFF00),
              tabs: const [Tab(text: 'Joinable'), Tab(text: 'My challenges')],
            ),
          ),
          body: _controller.isLoading && _controller.joinable.isEmpty && _controller.myChallenges.isEmpty
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFDFFF00)))
              : Column(
                  children: [
                    if (_controller.error != null)
                      _ErrorBanner(message: _controller.error!, onRetry: _refresh),
                    if (_controller.message != null)
                      _MessageBanner(message: _controller.message!),
                    Expanded(
                      child: TabBarView(
                        controller: _tabs,
                        children: [
                          _ChallengeList(challenges: _controller.joinable, empty: 'No joinable challenges yet.', onTap: _controller.joinChallenge),
                          _ChallengeList(challenges: _controller.myChallenges, empty: 'You have not joined a challenge yet.', onTap: null),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ChallengeList extends StatelessWidget {
  const _ChallengeList({required this.challenges, required this.empty, required this.onTap});
  final List<Challenge> challenges;
  final String empty;
  final Future<bool> Function(Challenge challenge)? onTap;

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) return Center(child: Text(empty, style: const TextStyle(color: Colors.white54)));
    return RefreshIndicator(
      color: const Color(0xFFDFFF00),
      onRefresh: () async {},
      child: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: challenges.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return _ChallengeTile(
            challenge: challenge,
            onOpen: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChallengeDetailsPage(challenge: challenge, onJoin: onTap))),
          );
        },
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile({required this.challenge, required this.onOpen});
  final Challenge challenge;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111510),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.white.withValues(alpha: .08))),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(challenge.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))),
              Icon(challenge.isActive ? Icons.bolt : Icons.event, color: challenge.isActive ? const Color(0xFFDFFF00) : Colors.white54),
            ]),
            const SizedBox(height: 8),
            Text(challenge.description.isEmpty ? 'No description' : challenge.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 14),
            LinearProgressIndicator(value: challenge.progressRatio, minHeight: 6, backgroundColor: Colors.white12, color: const Color(0xFFDFFF00)),
            const SizedBox(height: 8),
            Text('${challenge.progress.toStringAsFixed(0)} / ${challenge.goal.toStringAsFixed(0)} goal', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => MaterialBanner(content: Text(message), actions: [TextButton(onPressed: onRetry, child: const Text('Retry'))]);
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, color: const Color(0xFFDFFF00).withValues(alpha: .16), padding: const EdgeInsets.all(12), child: Text(message, style: const TextStyle(color: Color(0xFFDFFF00))));
}
