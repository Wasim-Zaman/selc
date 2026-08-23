import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/utils/image_utils.dart';

part 'banner_image_state.dart';

// Cubit
class BannerImageCubit extends Cubit<BannerImageState> {
  BannerImageCubit() : super(const BannerImageInitial());

  Future<void> pickAndProcessBanner({
    int targetWidth = 1200,
    int targetHeight = 480,
  }) async {
    emit(const BannerImageProcessing());

    final resizedImage = await ImageUtils.pickAndResizeImage(
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );

    if (resizedImage != null) {
      emit(BannerImageSuccess(resizedImage));
    } else {
      emit(const BannerImageInitial());
    }
  }

  void reset() {
    emit(const BannerImageInitial());
  }
}
