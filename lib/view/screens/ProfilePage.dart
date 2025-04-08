import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:fluttertoast/fluttertoast.dart';

class ProfilePage extends StatefulWidget {

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  var selectedAvatar =     "https://icons.iconarchive.com/icons/hopstarter/superhero-avatar/256/Avengers-Captain-America-icon.png";


  void displayBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Enter your name",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.black54,
                          letterSpacing: 1.0)),
                  TextField(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          child: Container(
                            width: 100,
                            height: 40,
                            child: Text("Save"),
                          ),
                          onPressed: () {
                            Fluttertoast.showToast(
                                msg: "Profile Updated",
                                toastLength: Toast.LENGTH_SHORT);
                            Navigator.pop(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()),
                            );
                          })
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    Color backGround = Color(0xFF092C28);
    Color circle_color = Color(0xFFAAC97B);
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: DrawFig(),
        ),
        Positioned(
            top: _height * 0.12,
            left: _width * 0.10,
            child: Column(
              children: [
                Text(
                  "Sunshar Pichai",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.grey[200],
                      letterSpacing: 1.0),
                ),
                Text(
                  "sundharpichai@gmail.com",
                  style: TextStyle(color: Colors.grey[200], fontSize: 15),
                ),
              ],
            )),
        Positioned(
          top: _height * 0.15,
          right: _width * 0.15,
          child: Center(
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  selectedAvatar            ),
              radius: 50,
            ),
          ),
        ),
      ],
    );
  }
}

class DrawFig extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..shader = ui.Gradient.linear(
          Offset(size.width * 0.20, size.height * 0.45),
          Offset(size.width * 0.50, size.height * 0.45),
          [Colors.black54, Colors.black54.withOpacity(0.9)]);
    var path = Path();
    path.lineTo(0, size.height * 0.20);
    path.lineTo(size.width * 0.20, size.height * 0.25);
    //Added this line
    path.relativeQuadraticBezierTo(47, 18, 100, -5);
    path.lineTo(size.width, size.height * 0.15);
    path.lineTo(size.width, 0);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}