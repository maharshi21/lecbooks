import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rive/rive.dart';

class Loader extends StatefulWidget {
  final BuildContext context;

  final Widget child;

  final IndicatorController controller;

  const Loader({
    Key? key,
    required this.context,
    required this.child,
    required this.controller,
  }) : super(key: key);

  @override
  State<Loader> createState() => _LoaderState(
        this.context,
        this.child,
        this.controller,
      );
}

class _LoaderState extends State<Loader> {
  final BuildContext context;

  final Widget child;

  final IndicatorController controller;

  _LoaderState(this.context, this.child, this.controller);

  bool _renderCompleteState = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        return Stack(children: [
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.09),
            child: Container(
                color: Colors.grey[200],
                width: MediaQuery.of(context).size.width,
                height: 150 * controller.value,
                child: SpinKitCircle(
                  color: Color(0xFF0D47A1),
                )),
          ),
          Transform.translate(
            offset: Offset(0.0, 150 * controller.value),
            child: controller.isLoading ? Container() : child,
          )
        ]);
      },
    );
  }
}
