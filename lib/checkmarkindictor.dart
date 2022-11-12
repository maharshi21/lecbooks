import 'dart:ffi';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'homepagewidget.dart';

class CheckMarkIndicator extends StatefulWidget {
  final Widget child;
  final onrefresh;

  const CheckMarkIndicator({
    Key? key,
    required this.child,
    required this.onrefresh,
  }) : super(key: key);

  @override
  _CheckMarkIndicatorState createState() => _CheckMarkIndicatorState();
}

class _CheckMarkIndicatorState extends State<CheckMarkIndicator>
    with SingleTickerProviderStateMixin {
  Future<void> _onrefresh() async {
    setState(() {});
    print('ok');
  }

  static const _indicatorSize = 150.0;

  /// Whether to render check mark instead of spinner
  bool _renderCompleteState = false;

  ScrollDirection prevScrollDirection = ScrollDirection.idle;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      offsetToArmed: _indicatorSize,
      onRefresh: () => widget.onrefresh,
      child: widget.child,
      completeStateDuration: const Duration(seconds: 1),
      onStateChanged: (change) {
        /// set [_renderCompleteState] to true when controller.state become completed
        if (change.didChange(to: IndicatorState.complete)) {
          setState(() {
            _renderCompleteState = true;
          });

          /// set [_renderCompleteState] to false when controller.state become idle
        } else if (change.didChange(to: IndicatorState.idle)) {
          setState(() {
            _renderCompleteState = false;
          });
        }
      },
      builder: (
        BuildContext context,
        Widget child,
        IndicatorController controller,
      ) {
        return Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: controller,
              builder: (BuildContext context, Widget? _) {
                if (controller.scrollingDirection == ScrollDirection.reverse &&
                    prevScrollDirection == ScrollDirection.forward) {
                  controller.stopDrag();
                }

                prevScrollDirection = controller.scrollingDirection;

                final containerHeight = controller.value * _indicatorSize;

                return Container(
                  color: Colors.grey.shade100,
                  alignment: Alignment.center,
                  height: containerHeight,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    child: OverflowBox(
                      maxHeight: 40,
                      minHeight: 40,
                      maxWidth: 40,
                      minWidth: 40,
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        alignment: Alignment.center,
                        child: _renderCompleteState
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                              )
                            : SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: const AlwaysStoppedAnimation(
                                      Color(0xFF0D47A1)),
                                  value: controller.isDragging ||
                                          controller.isArmed
                                      ? controller.value.clamp(0.0, 1.0)
                                      : null,
                                ),
                              ),
                        decoration: BoxDecoration(
                          color: _renderCompleteState
                              ? Color(0xFF0D47A1)
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0.0, controller.value * _indicatorSize),
                  child: child,
                );
              },
              animation: controller,
            ),
          ],
        );
      },
    );
  }
}
