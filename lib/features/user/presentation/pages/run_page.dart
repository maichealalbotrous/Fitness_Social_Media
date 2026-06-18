import 'package:fitness_social_app/features/user/presentation/components/run/run_header.dart';
import 'package:fitness_social_app/features/user/presentation/components/run/run_mobile_navigation.dart';
import 'package:fitness_social_app/features/user/presentation/components/run/run_post_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/run/run_stats_grid.dart';
import 'package:fitness_social_app/features/user/presentation/components/run/run_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_sidebar.dart';
import 'package:flutter/material.dart';

class RunPage extends StatelessWidget {
  const RunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RunTheme.background,
      drawer: const AppSidebar(activeSection: AppSidebarSection.runs),
      bottomNavigationBar: const RunMobileNavigation(),
      body: SafeArea(
        child: Scrollbar(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: RunTheme.background,
                surfaceTintColor: Colors.transparent,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                title: const _RunLogo(),
                centerTitle: false,
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(18, 18, 18, 120),
                sliver: SliverToBoxAdapter(child: _RunContent()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RunContent extends StatelessWidget {
  const _RunContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RunHeader(),
        SizedBox(height: 22),
        RunStatsGrid(),
        SizedBox(height: 22),
        RunPostCard(),
      ],
    );
  }
}

class _RunLogo extends StatelessWidget {
  const _RunLogo();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'REP',
            style: TextStyle(
              color: RunTheme.lime,
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
