import 'package:flutter/material.dart';

import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/follows/presentation/controllers/follow_controller.dart';
import 'package:fitness_social_app/features/user/data/local_profile_storage.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/local_profile_controller.dart';
import 'package:fitness_social_app/features/follows/presentation/follows_dependencies.dart';
import 'package:fitness_social_app/features/follows/presentation/pages/follow_list_page.dart';
import 'package:fitness_social_app/features/user/presentation/components/profile/profile_header_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/profile/profile_mobile_navigation.dart';
import 'package:fitness_social_app/features/user/presentation/components/profile/profile_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_sidebar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({this.targetUserId, this.targetDisplayName, super.key});

  final String? targetUserId;
  final String? targetDisplayName;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final FollowController _followController;
  LocalProfileController? _profileController;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _followController = FollowsDependencies.createController();
    _loadFollowData();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    final storage = await LocalProfileStorage.create();
    final controller = LocalProfileController(
      sessionStorage: SecureSessionStorage(),
      profileStorage: storage,
    );
    await controller.load();
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() => _profileController = controller);
  }

  @override
  void dispose() {
    _followController.dispose();
    _profileController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _followController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: ProfileTheme.background,
          drawer: const AppSidebar(activeSection: AppSidebarSection.profile),
          bottomNavigationBar: const ProfileMobileNavigation(),
          body: SafeArea(
            child: RefreshIndicator(
              color: ProfileTheme.lime,
              onRefresh: _reload,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: ProfileTheme.background,
                    surfaceTintColor: Colors.transparent,
                    leading: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    title: const _ProfileLogo(),
                    centerTitle: false,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                    sliver: SliverToBoxAdapter(
                      child: ProfileHeaderCard(
                        followersCount: _followController.followers.length,
                        followingCount: _followController.following.length,
                        onFollowersTap: () => _openList(FollowListType.followers),
                        onFollowingTap: () => _openList(FollowListType.following),
                        onFollowTap: widget.targetUserId == null ? null : _toggleFollow,
                        isFollowing: _isFollowing,
                        displayName: _displayName,
                        email: _profileEmail,
                        avatarBase64: widget.targetUserId == null
                            ? _profileController?.avatarBase64
                            : null,
                        onAvatarTap: widget.targetUserId == null &&
                                _profileController != null
                            ? _pickAvatar
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String get _displayName {
    if (widget.targetUserId == null) {
      return _profileController?.displayName ?? 'Repflow athlete';
    }
    return widget.targetDisplayName?.trim().isNotEmpty == true
        ? widget.targetDisplayName!.trim()
        : 'Athlete ${_shortId(widget.targetUserId!)}';
  }

  String get _profileEmail {
    if (widget.targetUserId == null) {
      return _profileController?.email ?? '';
    }
    return '@user_${_shortId(widget.targetUserId!)}';
  }

  Future<void> _pickAvatar() async {
    await _profileController?.pickAvatar();
    if (mounted) setState(() {});
  }

  Future<void> _toggleFollow() async {
    final targetUserId = widget.targetUserId;
    if (targetUserId == null) return;
    final status = await _followController.toggle(targetUserId);
    if (!mounted || status == null) return;
    setState(() => _isFollowing = status.isFollowing);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(status.message)),
    );
  }

  Future<void> _loadFollowData() async {
    await Future.wait([
      _followController.loadFollowers(),
      _followController.loadFollowing(),
    ]);
    if (!mounted || widget.targetUserId == null) return;
    setState(() {
      _isFollowing = _followController.following.any(
        (user) => user.userId == widget.targetUserId,
      );
    });
  }

  Future<void> _reload() => _loadFollowData();

  Future<void> _openList(FollowListType type) async {
    final controller = FollowsDependencies.createController();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FollowListPage(type: type, controller: controller),
      ),
    );
    await _reload();
  }
}

String _shortId(String value) {
  final end = value.length < 8 ? value.length : 8;
  return value.substring(0, end);
}

class _ProfileLogo extends StatelessWidget {
  const _ProfileLogo();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'REP',
            style: TextStyle(
              color: ProfileTheme.lime,
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
