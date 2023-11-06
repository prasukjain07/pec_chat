import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pec_chat/screens/profile_screen.dart';
import 'package:pec_chat/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: isShowUsers
                ? FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .where(
                          'username',
                          isGreaterThanOrEqualTo: searchController.text,
                        )
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                        itemCount: (snapshot.data! as dynamic).docs.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  uid: (snapshot.data! as dynamic)
                                      .docs[index]['uid'],
                                ),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  (snapshot.data! as dynamic)
                                      .docs[index]['photoUrl'],
                                ),
                                radius: 16,
                              ),
                              title: Text(
                                (snapshot.data! as dynamic)
                                    .docs[index]['username'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('posts')
                        .orderBy('datePublished')
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return MasonryGridView.count(
                        crossAxisCount: 3,
                        itemCount: (snapshot.data! as dynamic).docs.length,
                        itemBuilder: (context, index) => Image.network(
                          (snapshot.data! as dynamic)
                              .docs[index]['postUrl'],
                          fit: BoxFit.cover,
                        ),
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      );
                    },
                  ),
          ),
          PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child: AppBar(
              backgroundColor: Colors.teal,
              title: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey,
                ),
                child: Form(
                  child: TextFormField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search for a user...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                    ),
                    onFieldSubmitted: (String _) {
                      setState(() {
                        isShowUsers = true;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
