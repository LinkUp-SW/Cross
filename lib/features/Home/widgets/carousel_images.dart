import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';

class CarouselImages extends StatefulWidget {
  final List<String> images;
  const CarouselImages({
    super.key,
    required this.images,
  });

  @override
  State<CarouselImages> createState() {
    return _CarouselImagesState();
  }
}

class _CarouselImagesState extends State<CarouselImages> {
  late CarouselController _carouselController;
  final ValueNotifier<double> _positionNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselController()
      ..addListener(() {
        setState(() {
          if (_carouselController.positions.isNotEmpty) {
            _positionNotifier.value = _carouselController.position.pixels *
                widget.images.length /
                _carouselController.position.maxScrollExtent;
          } else {
            _positionNotifier.value = 0.0;
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400.w,
      height: 300.h,
      child: ValueListenableBuilder(
        valueListenable: _positionNotifier,
        builder: (context, value, child) => Stack(
          children: [
            CarouselView(
              controller: _carouselController,
              itemSnapping: true,
              itemExtent: 400.r,
              children: List<Widget>.generate(
                widget.images.length,
                (int index) {
                  return Image.network(
                    widget.images[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Positioned(
              top: 15.h,
              right: 15.w,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Text(
                    '${_positionNotifier.value.ceil() == 0 ? '1': _positionNotifier.value.ceil()} / ${widget.images.length}',
                    style: const TextStyle(color: AppColors.lightMain),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
