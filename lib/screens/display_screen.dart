import 'dart:convert';

import 'package:comments_app/model/comment.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:comments_app/screens/comment_Screen.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({Key? key}) : super(key: key);

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  int _selectedIndex = 0;
  List<Comment> comments = [];
  List<Comment> filteredComments = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final preferences = await SharedPreferences.getInstance();
    final commentList = preferences.getStringList('comments') ?? [];

    setState(() {
      comments = commentList
          .map((comment) => Comment.fromMap(jsonDecode(comment)))
          .toList();
      filteredComments = comments;
    });
  }

  Future<void> _saveComments() async {
    final preferences = await SharedPreferences.getInstance();
    final commentList =
        comments.map((comment) => jsonEncode(comment.toMap())).toList();

    await preferences.setStringList('comments', commentList.cast<String>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const Text(
                      'Add Comments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Image.asset(
                      'asset/comments.png',
                      height: 200,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 50,
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  _filterComments(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: filteredComments.length,
                itemBuilder: (BuildContext context, int index) {
                  final comment = filteredComments[index];
                  final truncatedComment = comment.title.length > 50
                      ? '${comment.title.substring(0, 20)}...'
                      : comment.title;

                  return Container(
                    width: double.infinity,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(comment.thumbnailUrl),
                        ),
                        title: Text(truncatedComment),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteComment(index);
                          },
                        ),
                        onTap: () {
                          _navigateToCommentDetails(comment);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addComment();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(color: Colors.blue),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined),
            label: 'Add Card',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _addComment() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newComment = '';
        final commentFocusNode = FocusNode();
        return AlertDialog(
          title: const Text('Type Below'),
          content: TextField(
            focusNode: commentFocusNode,
            onChanged: (value) {
              newComment = value;
            },
            decoration: const InputDecoration(hintText: 'Enter the Comment'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (newComment.isNotEmpty) {
                    final comment = Comment(
                      id: comments.length + 1,
                      title: newComment,
                      thumbnailUrl:
                          'https://www.google.com/s2/favicons?sz=64&domain_url=yahoo.com',
                      url: 'https://yahoo.com',
                    );
                    comments.add(comment);
                    filteredComments = comments;
                  }
                });

                _saveComments();
                Navigator.of(context).pop();
                _showSnackBar('Comment successfully added');
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteComment(int index) {
    setState(() {
      comments.removeAt(index);
      filteredComments = comments;
    });
    _saveComments();
    _showSnackBar('Comment successfully deleted');
  }

  void _navigateToCommentDetails(Comment comment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentScreen(comment: comment.title),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _filterComments(String searchTerm) {
    setState(() {
      if (searchTerm.isEmpty) {
        filteredComments = comments;
      } else {
        filteredComments = comments.where((comment) {
          final title = comment.title.toLowerCase();
          if (title.contains(searchTerm.toLowerCase())) {
            return true;
          } else {
            try {
              final id = int.parse(searchTerm);
              if (comment.id == id) {
                return true;
              }
            } catch (e) {
              // Ignore parsing errors for non-integer search terms
            }
          }
          return false;
        }).toList();
      }
    });
  }
}
