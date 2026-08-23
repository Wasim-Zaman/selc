part of 'banner_image_cubit.dart';

// States

abstract class BannerImageState extends Equatable {
  const BannerImageState();

  @override
  List<Object?> get props => [];
}

class BannerImageInitial extends BannerImageState {
  const BannerImageInitial();
}

class BannerImageProcessing extends BannerImageState {
  const BannerImageProcessing();
}

class BannerImageSuccess extends BannerImageState {
  final File imageFile;

  const BannerImageSuccess(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class BannerImageFailure extends BannerImageState {
  final String message;

  const BannerImageFailure(this.message);

  @override
  List<Object?> get props => [message];
}
