import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pec_chat/models/user.dart' as model;
import 'package:pec_chat/providers/user_provider.dart';
import 'package:pec_chat/resources/firestore_methods.dart';
import 'package:pec_chat/screens/comments_screen.dart';
import 'package:pec_chat/utils/colors.dart';
import 'package:pec_chat/utils/global_variable.dart';
import 'package:pec_chat/utils/utils.dart';
import 'package:pec_chat/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
        border: Border.all(
          color: Colors.black
        ),
        color: Colors.teal,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 5,
      ),
      child: Column(
        children: [
          // HEADER SECTION OF THE POST
          Container(
            
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    widget.snap['profImage'].toString(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.snap['username'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.snap['uid'].toString() == user.uid
                    ? IconButton(
                      color: Colors.black,
                        onPressed: () {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ListView(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shrinkWrap: true,
                                    children: [
                                      'Delete',
                                    ]
                                        .map(
                                          (e) => InkWell(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Text(e),
                                              ),
                                              onTap: () {
                                                deletePost(
                                                  widget.snap['postId']
                                                      .toString(),
                                                );
                                                // remove the dialog box
                                                Navigator.of(context).pop();
                                              }),
                                        )
                                        .toList()),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.more_vert)
                      )
                    : Container(),
              ],
            ),
          ),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () {
              FireStoreMethods().likePost(
                widget.snap['postId'].toString(),
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: widget.snap['postUrl'].toString(),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
AnimatedOpacity(
  duration: const Duration(milliseconds: 200),
  opacity: isLikeAnimating ? 1 : 0,
  child: LikeAnimation(
    isAnimating: isLikeAnimating,
    duration: const Duration(milliseconds: 400),
    onEnd: () {
      setState(() {
        isLikeAnimating = false;
      });
    },
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white), // Add black border
      ),
      child: const Icon(
        Icons.favorite,
        color: Colors.white,
        size: 100,
      ),
    ),
  ),
),

              ],
            ),
          ),
          // LIKE, COMMENT SECTION OF THE POST
          Row(
            children: <Widget>[
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user.uid),
                smallLike: true,
                child: IconButton(
                  icon: widget.snap['likes'].contains(user.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border,
                          color: Colors.black
                        ),
                  onPressed: () => FireStoreMethods().likePost(
                    widget.snap['postId'].toString(),
                    user.uid,
                    widget.snap['likes'],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.comment_outlined,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentsScreen(
                      postId: widget.snap['postId'].toString(),
                    ),
                  ),
                ),
              ),
              IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.black,
                  ),
                  onPressed: () {}),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                    icon: const Icon(Icons.bookmark_border), onPressed: () {}),
              ))
            ],
          ),
          //DESCRIPTION AND NUMBER OF COMMENTS
         Container(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          DefaultTextStyle(
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(fontWeight: FontWeight.w800, color: Colors.black),
            child: Text(
              '${widget.snap['likes'].length} likes',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'View all $commentLen comments',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CommentsScreen(
                  postId: widget.snap['postId'].toString(),
                ),
              ),
            ),
          ),
        ],
      ),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          top: 8,
        ),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: widget.snap['username'].toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' ${widget.snap['description']}',
              ),
            ],
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          DateFormat.yMMMd()
              .format(widget.snap['datePublished'].toDate()),
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    ],
  ),
)

        ],
      ),
    );
  }
}
