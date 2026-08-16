import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';
import 'package:flutter/material.dart';

import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/user/data/local_profile_storage.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/local_profile_controller.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/local_profile_avatar.dart';

enum AppSidebarSection { feed, workouts, runs, profile }

class AppSidebar extends StatelessWidget {
  const AppSidebar({required this.activeSection, super.key});

  final AppSidebarSection activeSection;

  static const _background = Color(0xFF030403);
  static const _lime = Color(0xFFDFFF00);
  static const _muted = Color(0xFF858585);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 16, 18),
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
              const _StaticSidebarItem(icon: Icons.search, label: 'Search'),
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
                  onPressed: () {},
                  child: const Text(
                    'Log Workout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const Spacer(),
              const _CurrentUserTile(),
            ],
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
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _controller?.displayName ?? 'Repflow athlete';
    return Row(
      children: [
        LocalProfileAvatar(base64Image: _controller?.avatarBase64),
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
        const Icon(Icons.more_horiz, color: AppSidebar._muted),
      ],
    );
  }
}
