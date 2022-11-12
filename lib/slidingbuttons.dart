import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SlideButton(label1: '1', label2: '2', onSelected: (a) {}),
      ),
    );
  }
}

typedef SlideEvent = void Function(String selectedLabel);

class SlideButton extends StatefulWidget {
  final String label1;
  final String label2;
  final SlideEvent onSelected;
  SlideButton({
    required this.label1,
    required this.label2,
    required this.onSelected,
  });
  @override
  _SlideButtonState createState() => _SlideButtonState();
}

class _SlideButtonState extends State<SlideButton> {
  double buttonPosition = 125.0;
  String? event;
  double _width = 70;

  void onfastforwardtap() {
    print('fastforward');
  }

  void onfastrewindtap() {
    print('fastrewind');
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: -1,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 70,
        height: 340.0,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: RotatedBox(
                quarterTurns: -3,
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  width: 110.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 3),
                  ),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(
                      Icons.fast_rewind,
                      color: Colors.grey.shade400,
                    ),
                  )),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RotatedBox(
                quarterTurns: -3,
                child: Container(
                  margin: EdgeInsets.only(right: 30),
                  width: 120.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Icon(
                      Icons.fast_forward,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: buttonPosition,
              child: GestureDetector(
                onPanUpdate: onPanUpdate,
                onPanEnd: onPanEnd,
                child: RotatedBox(
                  quarterTurns: -3,
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent,
                          blurRadius:
                              8, // has the effect of softening the shadow
                          spreadRadius:
                              20.0, // has the effect of extending the shadow
                          offset: Offset(
                            0.0, // horizontal, move right 10
                            0.0, // vertical, move down 10
                          ),
                        ),
                      ],
                    ),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: Icon(
                        Icons.play_arrow,
                        size: 40,
                        color: Colors.white,
                      ),
                    )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      buttonPosition += details.delta.dy;
      if (buttonPosition < 30) {
        buttonPosition = 30;
      } else if (buttonPosition > 220) {
        buttonPosition = 220;
      }

      if (buttonPosition < 80) {
        event = widget.label1;
      } else if (buttonPosition > 140) {
        _width = 50;

        event = widget.label2;
      } else {
        event = null;
      }
    });
  }

  void onPanEnd(DragEndDetails details) {
    setState(() {
      buttonPosition = 125;
      if (event != null) widget.onSelected(event!);
    });
  }
}
