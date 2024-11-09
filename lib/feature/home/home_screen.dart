import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipes/feature/favourite/favourite_screen.dart';
import 'package:recipes/feature/home/home_controller.dart';
import 'package:recipes/feature/recipes/recipes_screen.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: buildBody(),
          bottomNavigationBar: buildBottomNavigationBar(),
        ));
  }

  Widget buildBody() => Builder(builder: (context) {
        return IndexedStack(
          index: controller.index.value,
          children: [FavouriteScreen(), RecipesScreen(), buildBody3()],
        );
      });

  Widget buildBody3() => Container(
        child: Text("Screen 3"),
      );

  BottomNavigationBar buildBottomNavigationBar() => BottomNavigationBar(
          onTap: (int index) => controller.changeIndex(index),
          selectedItemColor: Colors.red,
          currentIndex: controller.index.value,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border), label: "Favourite"),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "List"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "icon")
          ]);
}
