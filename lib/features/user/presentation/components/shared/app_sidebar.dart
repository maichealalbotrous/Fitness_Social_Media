import 'package:fitness_social_app/features/auth/presentation/auth_dependencies.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';
import 'package:flutter/material.dart';

import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/user/data/local_profile_storage.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/local_profile_controller.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/local_profile_avatar.dart';
import 'package:fitness_social_app/features/user/presentation/user_dependencies.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/user_controller.dart';

enum AppSidebarSection { feed, workouts, runs, profile, community }

class AppSidebar extends StatelessWidget {
  const AppSidebar({required this.activeSection, super.key});

  final AppSidebarSection activeSection;

  static const _background = Color(0xFF030403);
  static const _lime = Color(0xFFDFFF00);
  static const _muted = Color(0xFF858585);

  static Future<void> _clearCachedProfile() async {
    final profileStorage = await LocalProfileStorage.create();
    await profileStorage.clear();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthDependencies.createLogoutUser()();
    } catch (_) {
      // Logout must still clear the local session when the API is unavailable.
    }
    await _clearCachedProfile();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.auth,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 16, 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SidebarLogo(),
              const SizedBox(height: 42),
              _SidebarItem(
                icon: Icons.home_outlined,
                label: 'Feed',
                active: activeSection == AppSidebarSection.feed,
                routeName: AppRoutes.feed,
              ),
              _SidebarItem(
                icon: Icons.fitness_center,
                label: 'Workouts',
                active: activeSection == AppSidebarSection.workouts,
                routeName: AppRoutes.workouts,
              ),
              _SidebarItem(
                icon: Icons.accessibility_new,
                label: 'Exercises',
                active: false,
                routeName: AppRoutes.exercises,
              ),
              _SidebarItem(
                icon: Icons.monitor_heart_outlined,
                label: 'Runs',
                active: activeSection == AppSidebarSection.runs,
                routeName: AppRoutes.runs,
              ),
              _SidebarItem(
                icon: Icons.person_outline,
                label: 'Profile',
                active: activeSection == AppSidebarSection.profile,
                routeName: AppRoutes.profile,
              ),
              _SidebarItem(
                icon: Icons.groups_outlined,
                label: 'Community',
                active: activeSection == AppSidebarSection.community,
                routeName: AppRoutes.community,
              ),
              _SidebarItem(
                icon: Icons.folder_shared_outlined,
                label: 'My Communities',
                active: activeSection == AppSidebarSection.community,
                routeName: AppRoutes.myCommunities,
              ),
              _SidebarItem(
                icon: Icons.flag_outlined,
                label: 'Challenges',
                active: false,
                routeName: AppRoutes.challenges,
              ),
              _SidebarItem(
                icon: Icons.sports,
                label: 'Coach',
                active: false,
                routeName: AppRoutes.coach,
              ),
              _SidebarItem(
                icon: Icons.people_alt_outlined,
                label: 'My Coaches',
                active: false,
                routeName: AppRoutes.myCoaches,
              ),
              _SidebarItem(
                icon: Icons.search,
                label: 'Search users',
                active: false,
                routeName: AppRoutes.userSearch,
              ),
              const _StaticSidebarItem(
                icon: Icons.notifications_none,
                label: 'Notifications',
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _lime,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () => _logout(context),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _CurrentUserTile(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.routeName,
  });

  final IconData icon;
  final String label;
  final bool active;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return _SidebarItemShell(
      icon: icon,
      label: label,
      active: active,
      onTap: () {
        if (active) {
          Navigator.pop(context);
          return;
        }

        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }
}

class _StaticSidebarItem extends StatelessWidget {
  const _StaticSidebarItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return _SidebarItemShell(icon: icon, label: label);
  }
}

class _SidebarItemShell extends StatelessWidget {
  const _SidebarItemShell({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 26),
        child: Row(
          children: [
            Icon(
              icon,
              color: active ? Colors.white : AppSidebar._muted,
              size: 27,
            ),
            const SizedBox(width: 18),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppSidebar._muted,
                fontSize: 18,
                fontWeight: active ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarLogo extends StatelessWidget {
  const _SidebarLogo();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'REP',
            style: TextStyle(
              color: AppSidebar._lime,
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

class _CurrentUserTile extends StatefulWidget {
  const _CurrentUserTile();

  @override
  State<_CurrentUserTile> createState() => _CurrentUserTileState();
}

class _CurrentUserTileState extends State<_CurrentUserTile> {
  LocalProfileController? _controller;
  UserController? _userController;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final profileStorage = await LocalProfileStorage.create();
    final controller = LocalProfileController(
      sessionStorage: SecureSessionStorage(),
      profileStorage: profileStorage,
    );
    await controller.load();
    final userController = UserDependencies.createController();
    final userId = controller.userId;
    if (userId != null && userId.isNotEmpty) {
      final remote = await userController.loadById(userId, forceRefresh: true);
      if (remote != null) {
        await controller.applyRemoteIdentity(
          displayName: remote.username,
          email: remote.email,
          avatarUrl: remote.profilePictureUrl,
        );
      }
    }
    if (!mounted) {
      controller.dispose();
      userController.dispose();
      return;
    }
    setState(() {
      _controller = controller;
      _userController = userController;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _userController?.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    setState(() => _isLoggingOut = true);
    try {
      try {
      await AuthDependencies.createLogoutUser()();
    } catch (_) {
      // Logout must still clear the local session when the API is unavailable.
    }
      await AppSidebar._clearCachedProfile();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.auth,
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _controller?.displayName ?? 'Repflow athlete';
    return Row(
      children: [
        LocalProfileAvatar(
          base64Image: _controller?.avatarBase64,
          imageUrl: _controller?.avatarUrl,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _controller?.email.isNotEmpty == true
                    ? '@${_controller!.email}'
                    : '@repflow_athlete',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppSidebar._muted, fontSize: 12),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          enabled: !_isLoggingOut,
          icon: _isLoggingOut
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.more_horiz, color: AppSidebar._muted),
          onSelected: (value) {
            if (value == 'logout') _logout(context);
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'logout',
              child: Text('Logout'),
            ),
          ],
        ),
      ],
    );
  }
}
