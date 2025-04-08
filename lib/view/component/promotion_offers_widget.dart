import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '/model/response/bannerListResponse.dart';
import '/view/component/shimmer_box.dart';
import '../../theme/CustomAppColor.dart';

class BannerListWidget extends StatefulWidget {
  late final List<BannerData> data;
  late final bool isInternetConnected;
  late final bool isLoading;
  late final bool isDarkMode;

  BannerListWidget({
    required this.data,
    required this.isInternetConnected,
    required this.isLoading,
    required this.isDarkMode,
  });

  @override
  _BannerListWidgetState createState() => _BannerListWidgetState();
}

class _BannerListWidgetState extends State<BannerListWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    PaintingBinding.instance.imageCache.maximumSize = 1000; // Adjust as needed
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100MB cache

    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < widget.data.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0; // Loop back to the first page
        }

        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double mediaWidth = MediaQuery.of(context).size.width;
    return widget.isInternetConnected && !widget.isLoading
        ? widget.data.isNotEmpty
            ? Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 5, top: 4),
                    width: mediaWidth,
                    height: screenHeight * 0.2,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: widget.data.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          width: mediaWidth * 0.95,
                          child: Center(
                            child: Card(
                              color: Colors.white.withOpacity(0.8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              margin: EdgeInsets.zero,
                              child: Stack(
                                children: [
                                  widget.data[index].bannerImages?.isEmpty == true
                                      ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: CustomAppColor.Primary,
                                    ),
                                    padding: EdgeInsets.all(6),
                                    child: Image.asset(
                                      "assets/app_logo.png",
                                      width: mediaWidth,
                                      height: screenHeight * 0.25,
                                      fit: BoxFit.none,
                                    ),
                                  )
                                      : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Theme.of(context).cardColor,
                                        width: 0.3,
                                      ),
                                      color: widget.isDarkMode
                                          ? CustomAppColor.DarkCardColor
                                          : Colors.white,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedNetworkImage(
                                        imageUrl: "${widget.data[index].bannerImages ?? ""}",
                                        cacheManager: DefaultCacheManager(), // Ensures caching
                                        width: mediaWidth,
                                        height: screenHeight * 0.25,
                                        fit: BoxFit.cover,
                                        useOldImageOnUrlChange: true, // Avoid flickering
                                        placeholder: (context, url) => Shimmer.fromColors(
                                          baseColor: Colors.white38,
                                          highlightColor: widget.isDarkMode
                                              ? CustomAppColor.DarkCardColor
                                              : Colors.grey,
                                          child: Container(
                                            width: mediaWidth * 0.85,
                                            height: screenHeight * 0.25,
                                            decoration: BoxDecoration(
                                              color: widget.isDarkMode
                                                  ? CustomAppColor.DarkCardColor
                                                  : Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Image.asset(
                                          "assets/app_logo.png",
                                          width: mediaWidth * 0.95,
                                          height: screenHeight * 0.22,
                                          fit: BoxFit.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                        // I omit the part to build card items from the list
                      },
                    ),
                  ),
                  Container(
                    width: mediaWidth * 0.66,
                    height: screenHeight * 0.18,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22.0, vertical: 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black54,
                            ),
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: widget.data.length,
                              effect: WormEffect(
                                dotHeight: 5.0,
                                dotWidth: 5.0,
                                spacing: 5.0,
                                dotColor: Colors.white70,
                                activeDotColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                height: 8,
              )
        : ShimmerBoxes();
  }
}
