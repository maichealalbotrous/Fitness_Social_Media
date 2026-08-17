import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/user/domain/entities/user_profile.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/user_controller.dart';
import 'package:fitness_social_app/features/user/presentation/pages/profile_page.dart';
import 'package:fitness_social_app/features/user/presentation/user_dependencies.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  late final UserController _controller;
  final _queryController = TextEditingController();
  UserProfile? _result;

  @override
  void initState() {
    super.initState();
    _controller = UserDependencies.createController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text('Search users'),
        backgroundColor: const Color(0xFF050505),
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'مثال: test_two',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _controller.isLoading ? null : _search,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_controller.isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_controller.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _controller.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            if (_result case final user?)
              _UserResult(user: user, onTap: () => _openProfile(user)),
          ],
        ),
      ),
    );
  }

  Future<void> _search() async {
    final result = await _controller.loadByUsername(_queryController.text);
    if (!mounted) return;
    setState(() => _result = result);
  }

  Future<void> _openProfile(UserProfile user) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(
          targetUserId: user.id,
          targetDisplayName: user.username,
        ),
      ),
    );
  }
}

class _UserResult extends StatelessWidget {
  const _UserResult({required this.user, required this.onTap});

  final UserProfile user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF151515),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: user.profilePictureUrl?.isNotEmpty == true
              ? NetworkImage(user.profilePictureUrl!)
              : null,
          child: user.profilePictureUrl?.isNotEmpty == true
              ? null
              : const Icon(Icons.person_outline),
        ),
        title: Text(user.username, style: const TextStyle(color: Colors.white)),
        subtitle: Text(user.email, style: const TextStyle(color: Colors.white54)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }
}
