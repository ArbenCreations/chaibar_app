import 'dart:async';

import 'package:ChaatBar/model/response/rf_bite/bannerListResponse.dart';
import 'package:ChaatBar/view/component/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../theme/AppColor.dart';

class BannerListWidget extends StatefulWidget {
  late final List<BannerData> data;
  late final bool isInternetConnected;
  late final bool isLoading;
  late final bool isDarkMode;

  BannerListWidget(
      {required this.data,
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
    double screenWidth = MediaQuery.of(context).size.width;
    return widget.isInternetConnected && !widget.isLoading
        ?widget.data.isNotEmpty ?
       Stack(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 5, top: 12),
                width: screenWidth,
                height: screenHeight * 0.17,
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
                      width: screenWidth * 0.8,
                      child: Center(
                          child: Card(
                        color: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17)),
                        margin: EdgeInsets.zero,
                        child: Stack(
                          children: [
                            widget.data[index].bannerImages == ""
                                ? Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: AppColor.PRIMARY),
                                    padding: EdgeInsets.all(6),
                                    child: Image.asset(
                                      "assets/pizza_image.jpg",
                                      width: screenWidth * 0.85,
                                      height: screenHeight * 0.25,
                                      fit: BoxFit.none,
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: Theme.of(context).cardColor,
                                          width: 0.3),
                                      color: widget.isDarkMode ? AppColor.DARK_CARD_COLOR : Colors.white,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        "${widget.data[index].bannerImages}",
                                        width: screenWidth * 0.85,
                                        height: screenHeight * 0.25,
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return Container(
                                            child: Image.asset(
                                              "assets/pizza_image.jpg",
                                              width: screenWidth * 0.85,
                                              height: screenHeight * 0.2,
                                              fit: BoxFit.none,
                                            ),
                                          );
                                        },
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return Shimmer.fromColors(
                                              baseColor: Colors.white38,
                                              highlightColor:  widget.isDarkMode ? AppColor.DARK_CARD_COLOR : Colors.grey,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color:  widget.isDarkMode ? AppColor.DARK_CARD_COLOR : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0)),
                                                width: screenWidth*0.85,
                                                height: screenHeight * 0.25,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      )),
                    );
                    // I omit the part to build card items from the list
                  },
                ),
              ),
              Container(
                width: screenWidth*0.66,
                height: screenHeight * 0.18,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22.0, vertical: 0),
                    child: Container(

                      padding:
                      const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
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
            ],
          ): SizedBox(height: 8,)
        : ShimmerBoxes();
  }
}
