import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/teacher/viewCourse.dart';
import 'package:sms/widget/ListTile.dart';
import 'package:sms/widget/StudentSlidebar/StudentNavigationDrawerCourses.dart';

import 'CourseView.dart';


class StudentCourseView extends StatefulWidget {

  @override
  StudentCourseViewState createState() => StudentCourseViewState();
}

class StudentCourseViewState extends State<StudentCourseView> with SingleTickerProviderStateMixin{
  AnimationController animationController;
  bool isLoading = false;
  String token = "";
  int id = 0;
  String name = "";
  List<String> courses = [];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    getToken().then(updateToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "COURSES",
            style: TextStyle(color: Colors.white),

          ),
          backgroundColor: Color(0xFF398AE5),
          elevation: 0.0,
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: MediaQuery.of(context).size.width - 70,
              color: Color(0xFF398AE5),
              margin: EdgeInsets.only(left: 70.0),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      color: Colors.transparent.withOpacity(0.3)
                  ),
                  child: ListView.separated(
                    separatorBuilder: (context, counter) {
                      return Divider(height: 0.0, color: Color(0xFF398AE5).withOpacity(0.3),
                      );
                    },
                    itemBuilder: (context, counter){
                      return listTile(
                        onTap: (){
                          setState(() {
                            courseSave(courses[counter]);
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => new StudentViewCourse()),
                          );
                        },
                        title: courses[counter],
                        icon: Icons.subject,
                      );
                    },
                    itemCount:courses.length,
                  ),
                ),
              ),
            ),
            StudentNavigationDrawerCourse()
          ],
        )
    );
  }
  void updateToken(String token) {
    setState(() {
      this.token = token;
      getId().then(updateId);
      getAllCourses();
    });
  }
  Future<String> getToken() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token");
    return token;
  }
  void getAllCourses() async{
    String data = name;
    Map<String,String> headers = {
      'Content-type' : 'application/json',
      'Accept': 'application/json',
      'Authorization': "Bearer "+token
    };
    var response = await http.post("http://13.212.36.183:8081/getCoursesByStudent", body: data, headers: headers);
    var jsonData = null;
    jsonData = json.decode(response.body);
    if(response.statusCode == 200){
      setState(() {
        for(var i=0; i<jsonData.length; i++){
          courses.add(jsonData[i]['course']);
        }
      });
    }
  }
  Future<bool> courseSave(String course) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("course", course);
    // ignore: deprecated_member_use
    return sharedPreferences.commit();
  }

  Future<int> getId() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int id = sharedPreferences.getInt("id");
    return id;
  }

  void updateId(int id) {
    setState(() {
      this.id = id;
      getName().then(updateName);
    });
  }

  Future<String> getName() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String name = sharedPreferences.getString("name");
    return name;
  }

  void updateName(String name) {
    setState(() {
      this.name = name;
      getAllCourses();
    });
  }
}