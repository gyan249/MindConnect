import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'config.dart';

class GroupsScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const GroupsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final userJoinedGroupsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('joinedGroups')
        .snapshots();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: userJoinedGroupsStream,
        builder: (context, membershipSnapshot) {
          if (membershipSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final joinedIds = <String>{};
          if (membershipSnapshot.hasData) {
            for (var doc in membershipSnapshot.data!.docs) {
              joinedIds.add(doc.id); // doc id = groupId
            }
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No groups yet. Be the first to create one!'),
                );
              }

              final groups = snapshot.data!.docs;

              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final groupDoc = groups[index];
                  final data = groupDoc.data();
                  final groupId = groupDoc.id;

                  final name = data['name']?.toString() ?? 'Unnamed group';
                  final description =
                      data['description']?.toString() ?? 'No description';
                  final createdByName =
                      data['createdByName']?.toString() ?? 'Someone';
                  final createdAt = data['createdAt'];
                  DateTime? createdAtDate;
                  if (createdAt is Timestamp) {
                    createdAtDate = createdAt.toDate();
                  }

                  // Icon / thumbnail
                  final iconEmoji =
                      data['iconEmoji']?.toString() ??
                          name.characters.first.toUpperCase();

                  // Last message preview
                  final lastMessageText =
                      data['lastMessageText']?.toString() ?? '';
                  final lastMessageSender =
                      data['lastMessageSenderName']?.toString() ?? '';
                  final lastMessageTime = data['lastMessageTime'];
                  DateTime? lastMessageDate;
                  if (lastMessageTime is Timestamp) {
                    lastMessageDate = lastMessageTime.toDate();
                  }

                  final isMember = joinedIds.contains(groupId);

                  String subtitle = description;
                  if (lastMessageText.isNotEmpty) {
                    subtitle =
                        '$lastMessageSender: $lastMessageText';
                  }

                  String timeText = '';
                  if (lastMessageDate != null) {
                    timeText =
                        '${lastMessageDate.day}/${lastMessageDate.month} '
                        '${lastMessageDate.hour.toString().padLeft(2, '0')}:'
                        '${lastMessageDate.minute.toString().padLeft(2, '0')}';
                  } else if (createdAtDate != null) {
                    timeText =
                        'Created ${createdAtDate.day}/${createdAtDate.month}';
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withOpacity(0.1),
                      child: Text(
                        iconEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    title: Text(name),
                    subtitle: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (timeText.isNotEmpty)
                          Text(
                            timeText,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () async {
                            if (isMember) {
                              // Leave group
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('joinedGroups')
                                  .doc(groupId)
                                  .delete();
                            } else {
                              // Join group
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('joinedGroups')
                                  .doc(groupId)
                                  .set({
                                'name': name,
                                'joinedAt':
                                    FieldValue.serverTimestamp(),
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isMember
                                  ? Colors.green.withOpacity(0.1)
                                  : AppColors.primary.withOpacity(0.1),
                              border: Border.all(
                                color: isMember
                                    ? Colors.green
                                    : AppColors.primary,
                              ),
                            ),
                            child: Text(
                              isMember ? 'Joined' : 'Join',
                              style: TextStyle(
                                fontSize: 11,
                                color: isMember
                                    ? Colors.green.shade800
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      if (!isMember) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Join the group to start chatting.'),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupChatScreen(
                            groupId: groupId,
                            groupName: name,
                            userId: userId,
                            userName: userName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.group_add, color: Colors.white),
        onPressed: () => _showCreateGroupDialog(context),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool loading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Group'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Group Name',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a group name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setState(() {
                            loading = true;
                          });

                          try {
                            await FirebaseFirestore.instance
                                .collection('groups')
                                .add({
                              'name': nameController.text.trim(),
                              'description':
                                  descriptionController.text.trim(),
                              'createdBy': userId,
                              'createdByName': userName,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                            Navigator.pop(context);
                          } finally {
                            setState(() {
                              loading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userId;
  final String userName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.userId,
    required this.userName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _sending = false;

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
    });

    try {
      final messageRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages');

      await messageRef.add({
        'text': text,
        'senderId': widget.userId,
        'senderName': widget.userName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update last message preview on the group document
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'lastMessageText': text,
        'lastMessageSenderName': widget.userName,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesQuery = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: messagesQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child:
                        Text('No messages yet. Start the conversation!'),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final text = data['text']?.toString() ?? '';
                    final senderName =
                        data['senderName']?.toString() ?? 'Someone';
                    final senderId =
                        data['senderId']?.toString() ?? '';
                    final isMe = senderId == widget.userId;

                    DateTime? timestamp;
                    if (data['timestamp'] is Timestamp) {
                      timestamp =
                          (data['timestamp'] as Timestamp).toDate();
                    }

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primary.withOpacity(0.9)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              senderName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isMe
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              text,
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            if (timestamp != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '${timestamp.hour.toString().padLeft(2, '0')}:'
                                  '${timestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _sending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                    color: AppColors.primary,
                    onPressed: _sending ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
