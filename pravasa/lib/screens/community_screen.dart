import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _postController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _addPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    await _firestore.collection('posts').add({
      'username': _currentUser.email!.split('@')[0],
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
    });

    _postController.clear();
  }

  Future<void> _toggleLike(String postId, List likes) async {
    final email = _currentUser.email!;
    final isLiked = likes.contains(email);

    final ref = _firestore.collection('posts').doc(postId);
    await ref.update({
      'likes': isLiked
          ? FieldValue.arrayRemove([email])
          : FieldValue.arrayUnion([email])
    });
  }

  Future<void> _addComment(String postId, String comment, String postOwner) async {
    if (comment.trim().isEmpty) return;

    final ref = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();

    await ref.set({
      'user': _currentUser.email,
      'text': comment.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Save like for mutual detection
    if (_currentUser.email != postOwner) {
      await _firestore.collection('user_likes').add({
        'liker': _currentUser.email,
        'likedUser': postOwner,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Check mutual like
      final mutual = await _firestore
          .collection('user_likes')
          .where('liker', isEqualTo: postOwner)
          .where('likedUser', isEqualTo: _currentUser.email)
          .get();

      if (mutual.docs.isNotEmpty) {
        // Create chat room if not exists
        final chats = await _firestore
            .collection('chats')
            .where('users', arrayContains: _currentUser.email)
            .get();

        final alreadyExists = chats.docs.any((doc) {
          final users = List<String>.from(doc['users']);
          return users.contains(postOwner);
        });

        if (!alreadyExists) {
          await _firestore.collection('chats').add({
            'users': [_currentUser.email, postOwner],
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }

  Widget _buildPostItem(DocumentSnapshot postDoc) {
    final data = postDoc.data() as Map<String, dynamic>;
    final postId = postDoc.id;
    final likes = List<String>.from(data['likes'] ?? []);
    final commentController = TextEditingController();
    final postOwner = '${data['username']}@gmail.com'; // modify if different domain

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${data['username'] ?? 'User'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
            const SizedBox(height: 5),
            Text(data['text'] ?? '', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    likes.contains(_currentUser.email)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () => _toggleLike(postId, likes),
                ),
                Text('${likes.length} likes'),
              ],
            ),
            const Divider(),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                final comments = snapshot.data?.docs ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: comments.map((doc) {
                    final c = doc.data() as Map<String, dynamic>;
                    return Text(
                        '${c['user'].toString().split('@')[0]}: ${c['text']}');
                  }).toList(),
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _addComment(postId, commentController.text, postOwner);
                    commentController.clear();
                  },
                ),
              ],
            ),
            FutureBuilder<QuerySnapshot>(
              future: _firestore
                  .collection('chats')
                  .where('users', arrayContains: _currentUser.email)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final chats = snapshot.data!.docs;
                final canChat = chats.any((doc) {
                  final users = List<String>.from(doc['users']);
                  return users.contains(postOwner);
                });

                if (!canChat) return const SizedBox();

                return TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: postOwner,
                    );
                  },
                  icon: const Icon(Icons.chat_bubble),
                  label: const Text('Start Chat'),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        centerTitle: true,
        backgroundColor: Colors.teal, // Customizing app bar color
        elevation: 0, // Clean appearance without a shadow
      ),
      body: Column(
        children: [
          // Post input section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _postController,
                  decoration: const InputDecoration(
                    labelText: 'What’s on your mind?',
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addPost,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Post'),
                )
              ],
            ),
          ),
          const Divider(),
          // Posts list section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!.docs;
                if (posts.isEmpty) {
                  return const Center(child: Text('No posts yet.'));
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) =>
                      _buildPostItem(posts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
