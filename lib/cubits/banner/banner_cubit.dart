import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/banner/banner_state.dart';
import 'package:selc/models/banner.dart';

class BannerCubit extends Cubit<BannerState> {
  final Stream<List<BannerModel>> bannersStream;
  StreamSubscription? _bannerSubscription;

  BannerCubit({required this.bannersStream}) : super(BannerInitial()) {
    _initBanners();
  }

  void _initBanners() {
    emit(BannerLoading());
    _bannerSubscription = bannersStream.listen(
      (banners) {
        emit(BannerLoaded(banners: banners));
      },
      onError: (error) {
        emit(BannerError(error.toString()));
      },
    );
  }

  void updateCurrentIndex(int index) {
    if (state is BannerLoaded) {
      final currentState = state as BannerLoaded;
      emit(currentState.copyWith(currentIndex: index));
    }
  }

  @override
  Future<void> close() {
    _bannerSubscription?.cancel();
    return super.close();
  }
}
