import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/community/data/community_local_storage.dart';
import 'package:fitness_social_app/features/community/domain/entities/community.dart';
import 'package:fitness_social_app/features/community/presentation/pages/community_page.dart';

class MyCommunitiesPage extends StatefulWidget {
  const MyCommunitiesPage({super.key});

  @override
  State<MyCommunitiesPage> createState() => _MyCommunitiesPageState();
}

class _MyCommunitiesPageState extends State<MyCommunitiesPage> {
  final _storage = CommunityLocalStorage();
  List<Community> _communities = const <Community>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
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
    setState(() => _isLoading = true);
    final communities = await _storage.read();
    if (!mounted) return;
    setState(() {
      _communities = communities;
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
