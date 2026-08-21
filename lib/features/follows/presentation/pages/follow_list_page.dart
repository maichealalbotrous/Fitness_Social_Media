import 'package:flutter/material.dart';
import 'package:fitness_social_app/features/user/domain/entities/user_profile.dart';
import 'package:fitness_social_app/features/user/presentation/user_dependencies.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/user_controller.dart';

import 'package:fitness_social_app/features/follows/domain/entities/follow.dart';
import 'package:fitness_social_app/features/follows/presentation/controllers/follow_controller.dart';
import 'package:fitness_social_app/features/user/presentation/components/profile/profile_theme.dart';
import 'package:fitness_social_app/features/user/presentation/pages/profile_page.dart';

class FollowListPage extends StatefulWidget {
  const FollowListPage({
    required this.type,
    required this.controller,
    super.key,
  });

  final FollowListType type;
  final FollowController controller;

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

enum FollowListType { followers, following }

class _FollowListPageState extends State<FollowListPage> {
  late final FollowController _controller;
  late final UserController _userController;
  final Map<String, UserProfile> _profiles = <String, UserProfile>{};

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _userController = UserDependencies.createController();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _userController.dispose();
    super.dispose();
  }

  void _openUserProfile(FollowUser user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(
          targetUserId: user.userId,
          targetDisplayName:
              _profiles[user.userId]?.username ?? user.username,
        ),
      ),
    );
  }

  Future<void> _load() async {
    if (widget.type == FollowListType.followers) {
      await _controller.loadFollowers();
    } else {
      await _controller.loadFollowing();
    }
    if (!mounted) return;
    final users = widget.type == FollowListType.followers
        ? _controller.followers
        : _controller.following;
    final profiles = await Future.wait(
      users.map((user) => _userController.loadById(user.userId)),
    );
    if (!mounted) return;
    setState(() {
      for (final profile in profiles) {
        if (profile != null) _profiles[profile.id] = profile;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final users = widget.type == FollowListType.followers
            ? _controller.followers
            : _controller.following;
        return Scaffold(
          backgroundColor: ProfileTheme.background,
          appBar: AppBar(
            backgroundColor: ProfileTheme.background,
            foregroundColor: Colors.white,
            title: Text(
              widget.type == FollowListType.followers
                  ? 'FOLLOWERS'
                  : 'FOLLOWING',
            ),
          ),
          body: RefreshIndicator(
            color: ProfileTheme.lime,
            onRefresh: _load,
            child: _ListBody(
              users: users,
              isLoading: _controller.isLoading,
              errorMessage: _controller.errorMessage,
              onRetry: _load,
              profiles: _profiles,
              onUserTap: _openUserProfile,
            ),
          ),
        );
      },
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.users,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.profiles,
    required this.onUserTap,
  });

  final List<FollowUser> users;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;
  final Map<String, UserProfile> profiles;
  final ValueChanged<FollowUser> onUserTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading && users.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: ProfileTheme.lime));
    }
    if (errorMessage case final String message) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          _Message(message: message, onRetry: onRetry),
        ],
      );
    }
    if (users.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No accounts yet.', style: TextStyle(color: ProfileTheme.muted))),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _FollowUserTile(
        user: users[index],
        profile: profiles[users[index].userId],
        onTap: () => onUserTap(users[index]),
      ),
    );
  }
}

class _FollowUserTile extends StatelessWidget {
  const _FollowUserTile({required this.user, required this.profile, required this.onTap});

  final FollowUser user;
  final UserProfile? profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ProfileTheme.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ProfileTheme.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: ProfileTheme.panelDark,
            child: Icon(Icons.person_outline, color: ProfileTheme.muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              profile?.username ??
                  user.username ??
                  'Athlete ${_shortId(user.userId)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const Icon(Icons.chevron_right, color: ProfileTheme.muted),
        ],
        ),
      ),
    );
  }
}

String _shortId(String userId) {
  final end = userId.length < 8 ? userId.length : 8;
  return userId.substring(0, end);
}

class _Message extends StatelessWidget {
  const _Message({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: ProfileTheme.muted)),
        const SizedBox(height: 14),
        OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
