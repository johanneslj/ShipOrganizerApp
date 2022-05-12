import 'package:flutter/material.dart';

/// A widget to be shown whenever the app is waiting on a response
///
/// This widget is shown "above" the view
/// It disables everything under it on the page
///
/// The progress indicator is turned off or on depending on [inAsyncCall]
///
/// The opacity of the widget can be set using [opacity]
class LoadingOverlay extends StatelessWidget {
  final bool inAsyncCall;
  final Widget progressIndicator;
  final Widget child;
  final double opacity;

  const LoadingOverlay({
    Key? key,
    this.progressIndicator = const CircularProgressIndicator(
      strokeWidth: 1,
      color: Colors.blue,
    ),
    required this.child,
    required this.inAsyncCall,
    this.opacity = 0.3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.add(child);
    if (inAsyncCall) {
      Widget layOutProgressIndicator;
      layOutProgressIndicator = Center(child: progressIndicator);

      final modal = [
         Opacity(
          child: const ModalBarrier(dismissible: false, color: Colors.grey),
          opacity: opacity,
        ),
        layOutProgressIndicator
      ];
      widgetList += modal;
    }
    return Stack(
      children: widgetList,
    );
  }
}
