import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_test/camera_page/src/focus_painter.dart';
import 'package:google_mlkit_test/controller/camera_page_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Widget cameraBody() {
  return Consumer(
    builder: (context, ref, _) {
      final controller = ref.read(cameraPageProvider.notifier).controller;
      final image = ref.watch(cameraPageProvider.select((s) => s.image));
      final changingCameraLens =
          ref.watch(cameraPageProvider.select((s) => s.changingCameraLens));
      final frameLeftTopOffset =
          ref.watch(cameraPageProvider.select((s) => s.frameLeftTopOffset));
      final deviceHeight = MediaQuery.of(context).size.height;
      final deviceWidth = MediaQuery.of(context).size.width;

      ///端末の縦横を保存
      Future.delayed(const Duration(milliseconds: 150), () {
        ref.read(cameraPageProvider.notifier).initialFrameOffset(
              deviceHeight: deviceHeight,
              deviceWidth: deviceWidth,
            );
      });

      if (controller == null) {
        return Container();
      }
      if (controller.value.isInitialized == false) {
        return Container();
      }

      return Container(
        //color: background,
        child: image == null
            ? Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CameraPreview(controller),

                  //if (widget.customPaint != null) widget.customPaint!,

                  ///オーバーレイ
                  Positioned.fill(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.srcOut,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                backgroundBlendMode: BlendMode.dstOut,
                              ),
                            ),
                          ),

                          ///文字を映す部分
                          Positioned(
                            top: frameLeftTopOffset.dy,
                            left: frameLeftTopOffset.dx,
                            child: Container(
                              height:
                                  (deviceHeight / 3 - frameLeftTopOffset.dy) *
                                      2,
                              width:
                                  (deviceWidth / 2 - frameLeftTopOffset.dx) * 2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: frameLeftTopOffset.dy,
                    left: frameLeftTopOffset.dx,
                    child: Container(
                      height: (deviceHeight / 3 - frameLeftTopOffset.dy) * 2,
                      width: (deviceWidth / 2 - frameLeftTopOffset.dx) * 2,
                      decoration: const FocusPainter(
                        frameSFactor: .1,
                        gap: -2,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  /// 左
                  Positioned(
                    top: frameLeftTopOffset.dy + 15,
                    left: frameLeftTopOffset.dx - 15,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (DragUpdateDetails details) {
                        final delta = details.delta;
                        ref.read(cameraPageProvider.notifier).dragFrameDxSide(
                              dx: delta.dx,
                            );
                      },
                      child: SizedBox(
                        height:
                            (deviceHeight / 3 - frameLeftTopOffset.dy) * 2 - 30,
                        width: 30,
                      ),
                    ),
                  ),

                  /// 右
                  Positioned(
                    top: frameLeftTopOffset.dy + 15,
                    left: frameLeftTopOffset.dx +
                        (deviceWidth / 2 - frameLeftTopOffset.dx) * 2 -
                        15,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (DragUpdateDetails details) {
                        final delta = details.delta;
                        ref.read(cameraPageProvider.notifier).dragFrameDxSide(
                              dx: -delta.dx,
                            );
                      },
                      child: SizedBox(
                        height:
                            (deviceHeight / 3 - frameLeftTopOffset.dy) * 2 - 30,
                        width: 30,
                      ),
                    ),
                  ),

                  /// 上
                  Positioned(
                    top: frameLeftTopOffset.dy - 15,
                    left: frameLeftTopOffset.dx + 15,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (DragUpdateDetails details) {
                        final delta = details.delta;
                        ref.read(cameraPageProvider.notifier).dragFrameDySide(
                              dy: delta.dy,
                            );
                      },
                      child: SizedBox(
                        height: 30,
                        width:
                            (deviceWidth / 2 - frameLeftTopOffset.dx) * 2 - 30,
                      ),
                    ),
                  ),

                  /// 下
                  Positioned(
                    top: frameLeftTopOffset.dy +
                        (deviceHeight / 3 - frameLeftTopOffset.dy) * 2 -
                        15,
                    left: frameLeftTopOffset.dx + 15,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (DragUpdateDetails details) {
                        final delta = details.delta;
                        ref.read(cameraPageProvider.notifier).dragFrameDySide(
                              dy: -delta.dy,
                            );
                      },
                      child: SizedBox(
                        height: 30,
                        width:
                            (deviceWidth / 2 - frameLeftTopOffset.dx) * 2 - 30,
                      ),
                    ),
                  ),

                  ///左上
                  Positioned(
                    top: frameLeftTopOffset.dy - 15,
                    left: frameLeftTopOffset.dx - 15,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (DragUpdateDetails details) {
                        final delta = details.delta;
                        ref.read(cameraPageProvider.notifier).dragFrameCorner(
                              dx: delta.dx,
                              dy: delta.dy,
                            );
                      },
                      child: const SizedBox(
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),

                  ///左下
                  Positioned(
                    top: frameLeftTopOffset.dy +
                        (deviceHeight / 3 - frameLeftTopOffset.dy) * 2 -
                        15,
                    left: frameLeftTopOffset.dx - 15,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (DragUpdateDetails details) {
                        final delta = details.delta;
                        ref.read(cameraPageProvider.notifier).dragFrameCorner(
                              dx: delta.dx,
                              dy: -delta.dy,
                            );
                      },
                      child: const SizedBox(
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),

                  ///右上
                  Positioned(
                    top: frameLeftTopOffset.dy - 15,
                    left: frameLeftTopOffset.dx +
                        (deviceWidth / 2 - frameLeftTopOffset.dx) * 2 -
                        15,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (DragUpdateDetails details) {
                        final delta = details.delta;
                        ref.read(cameraPageProvider.notifier).dragFrameCorner(
                              dx: -delta.dx,
                              dy: delta.dy,
                            );
                      },
                      child: const SizedBox(
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),

                  ///右下
                  Positioned(
                    top: frameLeftTopOffset.dy +
                        (deviceHeight / 3 - frameLeftTopOffset.dy) * 2 -
                        15,
                    left: frameLeftTopOffset.dx +
                        (deviceWidth / 2 - frameLeftTopOffset.dx) * 2 -
                        15,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (DragUpdateDetails details) {
                        final delta = details.delta;
                        ref.read(cameraPageProvider.notifier).dragFrameCorner(
                              dx: -delta.dx,
                              dy: -delta.dy,
                            );
                      },
                      child: const SizedBox(
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),
                ],
              )
            : CameraPreview(controller),
      );
    },
  );
}
