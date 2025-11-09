import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'loading_screen_controller.dart';

class LoadingScreen {
  LoadingScreen._shareInstance();
  static final LoadingScreen _shared = LoadingScreen._shareInstance();
  factory LoadingScreen.instance() => _shared;
  bool _resultState = false;

  LoadingScreenController? _controller;

  void show({
    required BuildContext context,
    String text = "Loading",
  }) {
    if (_controller?.update(text) ?? false) {
      return;
    } else {
      _controller = showOverlay(context: context, text: text);
    }
  }

  void showResult({
    required String text,
  }) {
    if (_controller?.result(text) ?? false) {
      return;
    }
  }

  void hide() {
    _controller?.close();
    _controller = null;
    _resultState = false;
  }

  LoadingScreenController? showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final textController = StreamController<String>();
    textController.add(text);
    var localization = context.localizations;
    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * .8,
                maxHeight: size.width * .8,
                minWidth: size.width * .5,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder(
                  stream: textController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (_resultState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            const Icon(Icons.error_outline),
                            const SizedBox(height: 10),
                            Text(
                              snapshot.requireData.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                hide();
                              },
                              child: Text(localization.main_dialog_close),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            const CircularProgressIndicator(),
                            const SizedBox(height: 10),
                            Text(
                              snapshot.requireData.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        );
                      }
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    state.insert(overlay);

    return LoadingScreenController(
      close: () {
        textController.close();
        overlay.remove();
        return true;
      },
      update: (String text) {
        _resultState = false;
        textController.add(text);
        return true;
      },
      result: (String text) {
        _resultState = true;
        textController.add(text);
        return true;
      },
    );
  }
}
