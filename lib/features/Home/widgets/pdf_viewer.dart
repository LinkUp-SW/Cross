import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';

class PDFViewer extends StatefulWidget {
  final String url;
  const PDFViewer({super.key, required this.url});

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  final Completer<PDFViewController> _pdfViewController =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 420.h,
          child: PDF(
            backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
            swipeHorizontal: true,
            pageSnap: true,
            autoSpacing: true,
            fitEachPage: true,
            defaultPage: currentPage!,
            onRender: (pages) {
              log("page rendered: $pages");
            },
            onError: (error) {
              log(error.toString());
            },
            onPageError: (page, error) {
              log('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfViewController.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              log('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              log('page change: $page/$total');
              setState(() {
                currentPage = page;
                pages = total;
              });
            },
          ).cachedFromUrl(widget.url),
          //'https://www.sldttc.org/allpdf/21583473018.pdf'
        ),
        Positioned(
          left: 5.w,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              _pdfViewController.future.then((value) {
                if (currentPage! > 0) {
                  value.setPage(currentPage! - 1);
                  log('page: $currentPage');
                }
              });
            },
            child: CircleAvatar(
              radius: 25.r,
              backgroundColor: AppColors.darkBackground.withValues(alpha: 0.5),
              child: Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppColors.lightMain,
                size: 30.r,
              ),
            ),
          ),
        ),
        Positioned(
          right: 5.w,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              _pdfViewController.future.then((value) {
                if (currentPage! < pages! - 1) {
                  value.setPage(currentPage! + 1);
                  log('page: $currentPage');
                }
              });
            },
            child: CircleAvatar(
              radius: 25.r,
              backgroundColor: AppColors.darkBackground.withValues(alpha: 0.5),
              child: Icon(
                Icons.keyboard_arrow_right_rounded,
                color: AppColors.lightMain,
                size: 30.r,
              ),
            ),
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
                    '${currentPage!+1} / $pages',
                    style: const TextStyle(color: AppColors.lightMain),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
