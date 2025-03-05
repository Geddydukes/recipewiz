import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart' as models;

class FollowersPage extends StatelessWidget {
  final bool showFollowers; // true for followers, false for following

  const FollowersPage({
    super.key,
    required this.showFollowers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showFollowers ? 'Followers' : 'Following'),
      ),
      body: StreamBuilder<models.User?>(
        stream: context.read<AuthService>().onUserChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          final userIds = showFollowers ? user.followers : user.following;
          
          if (userIds.isEmpty) {
            return Center(
              child: Text(
                showFollowers
                    ? 'No followers yet'
                    : 'Not following anyone yet',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return FutureBuilder<List<models.User>>(
            future: context.read<AuthService>().getUsersByIds(userIds),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              }

              final users = snapshot.data ?? [];
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final otherUser = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: otherUser.photoUrl != null
                          ? NetworkImage(otherUser.photoUrl!)
                          : null,
                      child: otherUser.photoUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(otherUser.displayName),
                    subtitle: Text('${otherUser.favoriteRecipes.length} recipes'),
                    trailing: _buildFollowButton(context, otherUser),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, models.User otherUser) {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    final isFollowing = currentUser.following.contains(otherUser.id);

    return TextButton(
      onPressed: () {
        if (isFollowing) {
          context.read<AuthService>().unfollowUser(otherUser.id);
        } else {
          context.read<AuthService>().followUser(otherUser.id);
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: isFollowing ? Colors.grey : Theme.of(context).primaryColor,
      ),
      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
    );
  }
}
