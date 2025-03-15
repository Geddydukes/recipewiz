import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_profile.dart';

class FollowersPage extends StatefulWidget {
  final String userId;
  final bool showFollowers; // true for followers, false for following

  const FollowersPage({
    required this.userId,
    required this.showFollowers,
    Key? key,
  }) : super(key: key);

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  late Stream<List<UserProfile>> _usersStream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    final authService = context.read<AuthService>();
    // TODO: Implement stream from Firestore
    // This is a placeholder. You'll need to implement the actual stream
    _usersStream = Stream.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showFollowers ? 'Followers' : 'Following'),
      ),
      body: StreamBuilder<List<UserProfile>>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Text(
                widget.showFollowers
                    ? 'No followers yet'
                    : 'Not following anyone yet',
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(user.displayName[0].toUpperCase())
                      : null,
                ),
                title: Text(user.displayName),
                subtitle: Text(user.email),
                trailing: _buildFollowButton(user),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFollowButton(UserProfile otherUser) {
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;

    if (currentUser == null || currentUser.uid == otherUser.id) {
      return const SizedBox.shrink();
    }

    // TODO: Implement following status check
    final isFollowing = false;

    return TextButton(
      onPressed: () {
        if (isFollowing) {
          context.read<AuthService>().unfollowUser(otherUser.id);
        } else {
          context.read<AuthService>().followUser(otherUser.id);
        }
      },
      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
    );
  }
}
