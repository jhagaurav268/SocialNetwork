import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/pages/home.dart';
import 'package:flutter_application/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();

  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool isLoading = false;
  User user;

  bool _displayNameValid = true;
  bool _biovalid = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Display Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display Name Too Short",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
              hintText: "Update Bio",
              errorText: _biovalid ? null : "Bio Is Too Long"),
        ),
      ],
    );
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.length < 3 ||
          displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;

      bioController.text
          .trim()
          .length > 100
          ? _biovalid = false
          : _biovalid = true;
    });

    if (_displayNameValid && _biovalid) {
      usersRef.doc(widget.currentUserId).update({
        "displayName:": displayNameController.text,
        "bio": bioController.text,
      });
      SnackBar snackbar = SnackBar(content: Text("Profile Updated"));
      _scaffoldkey.currentState.showSnackBar(snackbar);
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.done),
            iconSize: 30.0,
            color: Colors.green,
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage:
                    CachedNetworkImageProvider(user.photoUrl),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      buildDisplayNameField(),
                      buildBioField(),
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: updateProfileData,
                  child: Text(
                    "Update Profile",
                    style: TextStyle(
                      color: Theme
                          .of(context)
                          .primaryColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: FlatButton.icon(
                    onPressed: logout,
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                    label: Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
