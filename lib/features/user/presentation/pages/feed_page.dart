import 'package:flutter/material.dart';

import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/posts/domain/entities/post.dart';
import 'package:fitness_social_app/features/posts/presentation/controllers/posts_controller.dart';
import 'package:fitness_social_app/features/posts/presentation/posts_dependencies.dart';
import 'package:fitness_social_app/features/posts/presentation/widgets/create_post_sheet.dart';
import 'package:fitness_social_app/features/posts/presentation/widgets/post_card.dart';
import 'package:fitness_social_app/features/user/presentation/pages/profile_page.dart';
import 'package:fitness_social_app/features/posts/presentation/widgets/post_details_page.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/feed_header.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/feed_mobile_navigation.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/identity_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/weekly_challenge_card.dart';
import 'package:fitness_social_app/features/user/data/local_profile_storage.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_sidebar.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/local_profile_controller.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/user_controller.dart';
import 'package:fitness_social_app/features/user/presentation/user_dependencies.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final PostsController _controller;
  late final UserController _userController;
  LocalProfileController? _profileController;
  bool _followingOnly = false;

  @override
  void initState() {
    super.initState();
    _controller = PostsDependencies.createController();
    _userController = UserDependencies.createController();
    _loadPosts();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    final storage = await LocalProfileStorage.create();
    final profileController = LocalProfileController(
      sessionStorage: SecureSessionStorage(),
      profileStorage: storage,
    );
    await profileController.load();
    if (!mounted) {
      profileController.dispose();
      return;
    }
    setState(() => _profileController = profileController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _userController.dispose();
    _profileController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listenables = <Listenable>[_controller];
    if (_profileController != null) listenables.add(_profileController!);
    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: FeedTheme.background,
          drawer: const AppSidebar(activeSection: AppSidebarSection.feed),
          bottomNavigationBar: const FeedMobileNavigation(),
          body: SafeArea(
            child: RefreshIndicator(
              color: FeedTheme.lime,
              backgroundColor: FeedTheme.panel,
              onRefresh: _loadPosts,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                    sliver: SliverToBoxAdapter(
                      child: _FeedContent(
                        controller: _controller,
                        onCreatePost: _openCreatePost,
                        followingOnly: _followingOnly,
                        currentUserId: _profileController?.userId,
                        currentUserName: _profileController?.displayName,
                        currentUserAvatar: _profileController?.avatarBase64,
                        onAll: () => _selectFeed(false),
                        onFollowing: () => _selectFeed(true),
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

  Future<void> _loadPosts() async {
    await _controller.loadFeed(followingOnly: _followingOnly);
    if (!mounted) return;
    final posts = List<Post>.of(_controller.posts);
    final profiles = await Future.wait(
      posts.map((post) => _userController.loadById(post.authorId)),
    );
    if (!mounted) return;
    for (var index = 0; index < posts.length; index++) {
      final profile = profiles[index];
      if (profile != null) {
        _controller.updatePostAuthorName(posts[index].id, profile.username);
      }
    }
  }

  Future<void> _selectFeed(bool followingOnly) async {
    if (_followingOnly == followingOnly) return;
    setState(() => _followingOnly = followingOnly);
    await _loadPosts();
  }

  Future<void> _openCreatePost() async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FeedTheme.panel,
      builder: (_) => CreatePostSheet(controller: _controller),
    );
  }
}

class _FeedContent extends StatelessWidget {
  const _FeedContent({
    required this.controller,
    required this.onCreatePost,
    required this.followingOnly,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserAvatar,
    required this.onAll,
    required this.onFollowing,
  });

  final PostsController controller;
  final VoidCallback onCreatePost;
  final bool followingOnly;
  final String? currentUserId;
  final String? currentUserName;
  final String? currentUserAvatar;
  final VoidCallback onAll;
  final VoidCallback onFollowing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedHeader(
          onCreate: onCreatePost,
          followingOnly: followingOnly,
          onAll: onAll,
          onFollowing: onFollowing,
        ),
        const SizedBox(height: 22),
        if (controller.isLoading && controller.posts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 72),
            child: Center(
              child: CircularProgressIndicator(color: FeedTheme.lime),
            ),
          )
        else if (controller.errorMessage case final String message)
          _FeedError(
            message: message,
            onRetry: () => controller.loadFeed(followingOnly: followingOnly),
          )
        else if (controller.posts.isEmpty)
          const _EmptyFeed()
        else ...[
          ...controller.posts.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: PostCard(
                post: post,
                onLike: () => controller.toggleLike(post),
                onDelete: () => _confirmDelete(context, controller, post),
                currentUserId: currentUserId,
                currentUserName: currentUserName,
                currentUserAvatar: currentUserAvatar,
                onAuthorTap: post.authorId == currentUserId
                    ? null
                    : () => _openAuthorProfile(
                        context,
                        post.authorId,
                        post.authorName,
                      ),
                onComment: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PostDetailsPage(post: post),
                  ),
                ),
              ),
            ),
          ),
          const IdentityCard(),
          const SizedBox(height: 18),
          const WeeklyChallengeCard(),
        ],
      ],
    );
  }

  void _openAuthorProfile(
    BuildContext context,
    String userId,
    String? displayName,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(
          targetUserId: userId,
          targetDisplayName: displayName,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PostsController controller,
    Post post,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنشور؟'),
        content: const Text('لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deletePost(post);
    }
  }
}

class _FeedError extends StatelessWidget {
  const _FeedError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: FeedTheme.muted, size: 34),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: FeedTheme.muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => onRetry(),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Text(
          'لا توجد منشورات بعد. كن أول من يشارك تقدمه.',
          textAlign: TextAlign.center,
          style: TextStyle(color: FeedTheme.muted, fontSize: 15),
        ),
      ),
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
