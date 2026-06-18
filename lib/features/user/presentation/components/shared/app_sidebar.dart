import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';
import 'package:flutter/material.dart';

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

class _CurrentUserTile extends StatelessWidget {
  const _CurrentUserTile();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: Color(0xFF151515),
          child: Icon(Icons.person, color: AppSidebar._muted),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Michael alboutros',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '@Michael alboutros',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppSidebar._muted, fontSize: 12),
              ),
            ],
          ),
        ),
        Icon(Icons.more_horiz, color: AppSidebar._muted),
      ],
    );
  }
}
