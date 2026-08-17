import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/community/data/community_local_storage.dart';
import 'package:fitness_social_app/features/community/domain/entities/community.dart';
import 'package:fitness_social_app/features/community/presentation/community_dependencies.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';
import 'package:fitness_social_app/features/community/presentation/controllers/community_controller.dart';
import 'package:fitness_social_app/features/community/presentation/pages/community_page.dart';

class MyCommunitiesPage extends StatefulWidget {
  const MyCommunitiesPage({super.key});

  @override
  State<MyCommunitiesPage> createState() => _MyCommunitiesPageState();
}

class _MyCommunitiesPageState extends State<MyCommunitiesPage> {
  final _storage = CommunityLocalStorage();
  late final CommunityController _controller;
  List<Community> _communities = const <Community>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = CommunityDependencies.createController();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed(AppRoutes.feed);
            }
          },
        ),
        title: const Text('My Communities'),
        backgroundColor: const Color(0xFF050505),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _communities.isEmpty
              ? const _EmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _communities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final community = _communities[index];
                      return _CommunityTile(
                        community: community,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CommunityPage(initialCommunityId: community.id),
                            ),
                          );
                          _load();
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CommunityPage()),
          );
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }

  Future<void> _load() async {
    if (mounted) setState(() => _isLoading = true);
    final cached = await _storage.read();
    await _controller.loadMyCommunities();
    if (!mounted) return;

    final remote = _controller.myCommunities;
    if (_controller.errorMessage == null) {
      for (final community in remote) {
        await _storage.save(community);
      }
      setState(() {
        _communities = remote;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _communities = cached;
      _isLoading = false;
    });
  }
}

class _CommunityTile extends StatelessWidget {
  const _CommunityTile({required this.community, required this.onTap});

  final Community community;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF151515),
      child: ListTile(
        onTap: onTap,
        leading: _CommunityThumbnail(imageUrl: community.imageUrl),
        title: Text(community.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '${community.isPrivate ? 'Private' : 'Public'} · ${community.memberCount} members',
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }
}

class _CommunityThumbnail extends StatelessWidget {
  const _CommunityThumbnail({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const CircleAvatar(
        backgroundColor: Color(0xFF2A2A2A),
        child: Icon(Icons.groups, color: Colors.white70),
      );
    }
    return CircleAvatar(backgroundImage: _imageProvider(imageUrl!));
  }

  ImageProvider<Object> _imageProvider(String value) {
    if (value.startsWith('data:')) {
      final comma = value.indexOf(',');
      if (comma > 0) {
        try {
          return MemoryImage(Uri.parse(value).data!.contentAsBytes());
        } catch (_) {
          return const AssetImage('assets/images/logo.png');
        }
      }
    }
    return NetworkImage(value);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Text(
          'لا توجد مجتمعات محفوظة بعد. أنشئ مجتمعاً أو افتح مجتمعاً ثم انضم إليه ليظهر هنا.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, height: 1.5),
        ),
      ),
    );
  }
}
