import 'package:flutter/material.dart';
import 'package:google_mlkit_test/camera_page/src/camera_body.dart';
import 'package:google_mlkit_test/camera_page/src/result_dialog.dart';
import 'package:google_mlkit_test/controller/camera_page_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(cameraPageProvider.select((s) => s.text));
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, text);
        return Future.value(true);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: cameraBody(),
        floatingActionButton: floatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget floatingActionButton() {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen(cameraPageProvider.select((s) => s.text), (previous, next) {
          if (next != null) {
            resultDialog(context: context, message: next);
          }
        });

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await ref.read(cameraPageProvider.notifier).takePicture();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: 76,
                    width: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 4,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
