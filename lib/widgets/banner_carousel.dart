import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerCarousel extends StatelessWidget {
  const BannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> banners = [
      'assets/images/banner1.jpg',
      'assets/images/banner2.jpg',
      'assets/images/banner3.jpg',
      'assets/images/banner4.jpg',
    ];

    return SizedBox(
      height: 200,
      child: CarouselSlider(
        items: banners.map((url) => ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            url,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        )).toList(),
        options: CarouselOptions(
          height: 200,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.92,
          autoPlayInterval: const Duration(seconds: 4),
        ),
      ),
    );
  }
}