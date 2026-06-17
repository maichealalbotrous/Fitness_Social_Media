import 'package:fitness_social_app/features/user/presentation/components/feed/activity_post_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/feed_app_drawer.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/feed_header.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/feed_mobile_navigation.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/identity_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/pr_post_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/weekly_challenge_card.dart';
import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FeedTheme.background,
      drawer: const FeedAppDrawer(),
      bottomNavigationBar: const FeedMobileNavigation(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: FeedTheme.background,
              surfaceTintColor: Colors.transparent,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: const _MobileLogo(),
              centerTitle: false,
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 28),
              sliver: SliverToBoxAdapter(child: _FeedContent()),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedContent extends StatelessWidget {
  const _FeedContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الصورة: links and header.png
        FeedHeader(),
        SizedBox(height: 22),

        // الصورة: post.png
        PrPostCard(),
        SizedBox(height: 20),
        ActivityPostCard(),
        SizedBox(height: 20),

        // الصورة: identify and weekly chalenges.png
        IdentityCard(),
        SizedBox(height: 18),
        WeeklyChallengeCard(),
      ],
    );
  }
}

class _MobileLogo extends StatelessWidget {
  const _MobileLogo();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'REP',
            style: TextStyle(
              color: FeedTheme.lime,
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
