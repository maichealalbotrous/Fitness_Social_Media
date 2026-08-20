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
import 'package:fitness_social_app/features/user/domain/entities/user_profile.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/user_controller.dart';
import 'package:fitness_social_app/features/user/presentation/user_dependencies.dart';
import 'package:fitness_social_app/features/physical_data/domain/physical_data_entities.dart';
import 'package:fitness_social_app/features/physical_data/presentation/physical_data_controller.dart';
import 'package:fitness_social_app/features/physical_data/presentation/physical_data_dependencies.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({this.targetUserId, this.targetDisplayName, super.key});

  final String? targetUserId;
  final String? targetDisplayName;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final FollowController _followController;
  late final UserController _userController;
  late final PhysicalDataController _physicalDataController;
  LocalProfileController? _profileController;
  UserProfile? _remoteProfile;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _followController = FollowsDependencies.createController();
    _userController = UserDependencies.createController();
    _physicalDataController = PhysicalDataDependencies.createController();
    _loadFollowData();
    if (widget.targetUserId != null) _loadRemoteProfile();
    if (widget.targetUserId == null) _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    final storage = await LocalProfileStorage.create();
    final controller = LocalProfileController(
      sessionStorage: SecureSessionStorage(),
      profileStorage: storage,
    );
    await controller.load();
    if (controller.userId != null) {
      await _physicalDataController.load(controller.userId!);
      _remoteProfile = await _userController.loadById(
        controller.userId!,
        forceRefresh: true,
      );
      final profile = _remoteProfile;
      if (profile != null) {
        await controller.applyRemoteIdentity(
          displayName: profile.username,
          email: profile.email,
          avatarUrl: profile.profilePictureUrl,
        );
      }
    }
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() => _profileController = controller);
  }

  @override
  void dispose() {
    _followController.dispose();
    _userController.dispose();
    _physicalDataController.dispose();
    _profileController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_followController, _userController, _physicalDataController]),
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
                      child: Column(
                        children: [
                          ProfileHeaderCard(
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
                        avatarUrl: _remoteProfile?.profilePictureUrl,
                        bio: _remoteProfile?.bio ?? '',
                        onBioEdit: widget.targetUserId == null ? _editBio : null,
                        onAvatarTap: widget.targetUserId == null &&
                                _profileController != null
                            ? _pickAvatar
                            : null,
                          ),
                          const SizedBox(height: 18),
                          _PhysicalDataCard(data: _physicalDataController.data),
                        ],
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
    return _remoteProfile?.username.trim().isNotEmpty == true
        ? _remoteProfile!.username.trim()
        : widget.targetDisplayName?.trim().isNotEmpty == true
        ? widget.targetDisplayName!.trim()
        : 'Athlete ${_shortId(widget.targetUserId!)}';
  }

  String get _profileEmail {
    if (widget.targetUserId == null) {
      return _profileController?.email ?? '';
    }
    return _remoteProfile?.email.isNotEmpty == true
        ? _remoteProfile!.email
        : '@user_${_shortId(widget.targetUserId!)}';
  }

  Future<void> _loadRemoteProfile() async {
    final targetUserId = widget.targetUserId;
    if (targetUserId == null) return;
    final profile = await _userController.loadById(
      targetUserId,
      forceRefresh: true,
    );
    await _physicalDataController.load(targetUserId);
    if (mounted && profile != null) setState(() => _remoteProfile = profile);
  }

  Future<void> _pickAvatar() async {
    final bytes = await _profileController?.pickAvatarBytes();
    if (bytes == null) return;
    final url = await _userController.uploadProfilePicture(
      fileName: 'profile.jpg',
      bytes: bytes,
    );
    if (url != null) {
      final updated = await _userController.updateProfile(profilePictureUrl: url);
      if (updated != null) _remoteProfile = updated;
    }
    if (!mounted) return;
    setState(() {});
    final error = _userController.errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _editBio() async {
    final controller = TextEditingController(text: _remoteProfile?.bio ?? '');
    final bio = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit bio'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          maxLength: 300,
          decoration: const InputDecoration(hintText: 'Tell the community about yourself'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (bio == null || !mounted) return;
    final updated = await _userController.updateProfile(bio: bio);
    if (!mounted) return;
    if (updated != null) {
      final refreshed = await _userController.loadById(
        updated.id,
        forceRefresh: true,
      );
      setState(() => _remoteProfile = refreshed ?? updated);
    } else if (_userController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_userController.errorMessage!)),
      );
    }
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

class _PhysicalDataCard extends StatelessWidget {
  const _PhysicalDataCard({required this.data});
  final UserPhysicalData? data;

  @override
  Widget build(BuildContext context) {
    final physical = data;
    if (physical == null) return const SizedBox.shrink();
    final latestWeight = physical.weights.isEmpty ? null : physical.weights.last.weightKg;
    final visibleFields = <Widget>[
      if (!physical.heightIsPrivate && physical.heightCm != null) _item(Icons.height, 'Height', '${physical.heightCm!.toStringAsFixed(1)} cm'),
      if (!physical.sexIsPrivate && physical.sex != null) _item(Icons.person_outline, 'Gender', physical.sex!.label),
      if (!physical.birthdayIsPrivate && physical.birthday != null) _item(Icons.cake_outlined, 'Birthday', '${physical.birthday!.year}-${physical.birthday!.month.toString().padLeft(2, '0')}-${physical.birthday!.day.toString().padLeft(2, '0')}'),
      if (!physical.weightsIsPrivate && latestWeight != null) _item(Icons.monitor_weight_outlined, 'Latest weight', '${latestWeight.toStringAsFixed(1)} kg'),
    ];
    return Card(
      color: ProfileTheme.panel,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Physical Data', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          if (visibleFields.isEmpty) const Text('No physical data available.', style: TextStyle(color: Colors.white60)) else Wrap(spacing: 12, runSpacing: 12, children: visibleFields),
          if (!physical.personalRecordsIsPrivate && physical.personalRecords.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Personal records', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ...physical.personalRecords.take(5).map((record) => ListTile(contentPadding: EdgeInsets.zero, dense: true, title: Text(record.exerciseName, style: const TextStyle(color: Colors.white)), trailing: Text('${record.maxWeightKg.toStringAsFixed(1)} kg', style: const TextStyle(color: ProfileTheme.lime, fontWeight: FontWeight.bold)))),
          ],
        ]),
      ),
    );
  }

  Widget _item(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: ProfileTheme.lime), const SizedBox(width: 8), Text('$label: $value', style: const TextStyle(color: Colors.white70))]),
  );
}
