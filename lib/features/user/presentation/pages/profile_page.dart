import 'package:fitness_social_app/features/user/presentation/components/profile/profile_header_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/profile/profile_mobile_navigation.dart';
import 'package:fitness_social_app/features/user/presentation/components/profile/profile_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_sidebar.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileTheme.background,
      drawer: const AppSidebar(activeSection: AppSidebarSection.profile),
      bottomNavigationBar: const ProfileMobileNavigation(),
      body: SafeArea(
        child: Scrollbar(
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
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 120),
                sliver: SliverToBoxAdapter(child: ProfileHeaderCard()),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
