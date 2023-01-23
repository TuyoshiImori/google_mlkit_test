import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

part 'camera_page_controller.freezed.dart';

@freezed
class CameraPageState with _$CameraPageState {
  const factory CameraPageState({
    @Default(<CameraDescription>[]) List<CameraDescription> cameras,
    @Default(false) bool changingCameraLens,
    @Default(false) bool hasFlash,
    @Default(-1) int cameraIndex,
    @Default(Offset.zero) Offset frameLeftTopOffset,
    @Default(false) bool hasDeviceSize,
    @Default(0) double deviceHeight,
    @Default(0) double deviceWidth,
    String? text,
    String? path,
    File? image,
  }) = _CameraPageState;
}

final cameraPageProvider =
    StateNotifierProvider.autoDispose<CameraPageController, CameraPageState>(
        (ref) {
  return CameraPageController();
});

class CameraPageController extends StateNotifier<CameraPageState> {
  CameraPageController() : super(const CameraPageState()) {
    _init();
  }

  final TextRecognizer textRecognizer =
      TextRecognizer(script: TextRecognitionScript.japanese);

  //ScreenMode mode = ScreenMode.liveFeed;
  CameraController? controller;
  final CameraLensDirection initialDirection = CameraLensDirection.back;
  final imagePicker = ImagePicker();

  Future<void> _init() async {
    final cameras = await availableCameras();
    var cameraIndex = -1;
    if (cameras.any(
      (e) => e.lensDirection == initialDirection && e.sensorOrientation == 90,
    )) {
      cameraIndex = cameras.indexOf(
        cameras.firstWhere(
          (element) =>
              element.lensDirection == initialDirection &&
              element.sensorOrientation == 90,
        ),
      );
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == initialDirection) {
          cameraIndex = i;
          break;
        }
      }
    }

    final camera = cameras[cameraIndex];
    controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,

      ///imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    if (controller != null) {
      await controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        controller!.getMaxZoomLevel();
        controller!.getMinZoomLevel();
        controller!.setZoomLevel(1);
      });
    }
  }

  void initialFrameOffset({
    required double deviceHeight,
    required double deviceWidth,
  }) {
    if (!state.hasDeviceSize) {
      state = state.copyWith(
        frameLeftTopOffset: Offset(
          deviceWidth / 10,
          deviceHeight / 6,
        ),
        deviceHeight: deviceHeight,
        deviceWidth: deviceWidth,
        hasDeviceSize: true,
      );
    }
  }

  Future<void> startLiveFeed() async {
    final camera = state.cameras[state.cameraIndex];
    controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,

      ///imageFormatGroup: ImageFormatGroup.bgra8888,
    );
    if (controller != null) {
      await controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
      });
    }
  }

  Future<void> processCameraImage({required XFile? image}) async {
    final path = image?.path;
    if (path == null) {
      return;
    }
    final properties = await FlutterNativeImage.getImageProperties(path);
    final propertiesHeight = properties.height;
    final propertiesWidth = properties.width;

    if (propertiesHeight != null && propertiesWidth != null) {
      final frameLeftTopOffset = state.frameLeftTopOffset;
      final deviceHeight = state.deviceHeight;
      final deviceWidth = state.deviceWidth;

      ///写真上の座標比率を画面座標と合わせる
      final originX = propertiesWidth * (frameLeftTopOffset.dx / deviceWidth);
      final originY = propertiesHeight * (frameLeftTopOffset.dy / deviceHeight);

      ///画面上の長さをImagePropertiesと合わせる
      final originWidth = ((deviceWidth / 2 - frameLeftTopOffset.dx) * 2) *
          (propertiesWidth / deviceWidth);
      final originHeight = ((deviceHeight / 3 - frameLeftTopOffset.dy) * 2) *
          (propertiesHeight / deviceHeight);
      final croppedFile = await FlutterNativeImage.cropImage(
        path,
        originX.toInt(),
        originY.toInt(),
        originWidth.toInt(),
        originHeight.toInt(),
      );
      state = state.copyWith(image: croppedFile);
      final inputImage = InputImage.fromFile(croppedFile);
      final recognizedText = await textRecognizer.processImage(inputImage);
      if (inputImage.inputImageData?.size != null &&
          inputImage.inputImageData?.imageRotation != null) {
        state = state.copyWith(
          text: recognizedText.text,
        );
      } else {
        state = state.copyWith(
          text: recognizedText.text,
        );
      }
    }
  }

  Future<void> takePicture() async {
    if (controller != null) {
      //await controller!.setFlashMode(FlashMode.off);
      final image = await controller!.takePicture();
      await processCameraImage(image: image);
    }
  }

  void dragFrameCorner({
    required double dx,
    required double dy,
  }) {
    final dxPosition = state.frameLeftTopOffset.dx + dx;
    final dyPosition = state.frameLeftTopOffset.dy + dy;
    final deviceHeight = state.deviceHeight;
    final deviceWidth = state.deviceWidth;
    final upperHeight = deviceHeight / 3 - 20;
    final upperWidth = deviceWidth / 2 - 20;
    final lowerHeight = deviceHeight / 6;
    final lowerWidth = deviceWidth / 10;

    if ((lowerWidth <= dxPosition && dxPosition <= upperWidth) &&
        (lowerHeight <= dyPosition && dyPosition <= upperHeight)) {
      state = state.copyWith(
        frameLeftTopOffset: Offset(dxPosition, dyPosition),
      );
    } else if (lowerHeight <= dyPosition && dyPosition <= upperHeight) {
      state = state.copyWith(
        frameLeftTopOffset: Offset(state.frameLeftTopOffset.dx, dyPosition),
      );
    } else if (lowerWidth <= dxPosition && dxPosition <= upperWidth) {
      state = state.copyWith(
        frameLeftTopOffset: Offset(dxPosition, state.frameLeftTopOffset.dy),
      );
    }
  }

  void dragFrameDxSide({
    required double dx,
  }) {
    final dxPosition = state.frameLeftTopOffset.dx + dx;
    final deviceWidth = state.deviceWidth;
    final upperWidth = deviceWidth / 2 - 30;
    final lowerWidth = deviceWidth / 10;
    if (lowerWidth <= dxPosition && dxPosition <= upperWidth) {
      state = state.copyWith(
        frameLeftTopOffset: Offset(dxPosition, state.frameLeftTopOffset.dy),
      );
    }
  }

  void dragFrameDySide({
    required double dy,
  }) {
    final dyPosition = state.frameLeftTopOffset.dy + dy;
    final deviceHeight = state.deviceHeight;
    final upperHeight = deviceHeight / 3 - 30;
    final lowerHeight = deviceHeight / 6;
    if (lowerHeight <= dyPosition && dyPosition <= upperHeight) {
      state = state.copyWith(
        frameLeftTopOffset: Offset(state.frameLeftTopOffset.dx, dyPosition),
      );
    }
  }
}
