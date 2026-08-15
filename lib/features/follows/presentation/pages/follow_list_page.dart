import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/follows/domain/entities/follow.dart';
import 'package:fitness_social_app/features/follows/presentation/controllers/follow_controller.dart';
import 'package:fitness_social_app/features/user/presentation/components/profile/profile_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() {
    return widget.type == FollowListType.followers
        ? _controller.loadFollowers()
        : _controller.loadFollowing();
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
  });

  final List<FollowUser> users;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;

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
          Center(child: Text('لا توجد حسابات بعد.', style: TextStyle(color: ProfileTheme.muted))),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _FollowUserTile(user: users[index]),
    );
  }
}

class _FollowUserTile extends StatelessWidget {
  const _FollowUserTile({required this.user});

  final FollowUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              user.username ?? 'Athlete ${_shortId(user.userId)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const Icon(Icons.chevron_right, color: ProfileTheme.muted),
        ],
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
        OutlinedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
      ],
    );
  }
}
