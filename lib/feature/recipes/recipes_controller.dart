import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:recipes/models/Meal.dart';

import '../../core/routing/routers.dart';
import '../favourite/favourite_controller.dart';

class RecipesController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  var isLoading = false.obs;
  var mealList = <Meal>[].obs;
  var categoriesList = <String>[].obs;
  final FavouriteController favouriteController =
      Get.find<FavouriteController>();

  Future<void> fetchRandomMeals() async {
    try {
      isLoading(true); // Đặt trạng thái chờ khi bắt đầu tải
      List<Meal> fetchedMeals = [];
      for (int i = 0; i < 10; i++) {
        final response = await http.get(
            Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          fetchedMeals.add(Meal.fromJson(data['meals'][0]));
          // return fetchedMeals.add(Meal.fromJson(jsonDecode(response.body) as Map<String, dynamic>));
        } else {
          throw Exception('Failed to load meal');
        }
      }

      mealList.value = fetchedMeals; // Cập nhật danh sách món ăn
      print("độ dai chuôi ${mealList.length}");
    } finally {
      isLoading(false); // Đặt trạng thái không chờ sau khi tải xong
    }
  }

  Future<void> fetchCategories() async {
    List<String> featchList = [];
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?c=list'));
    if(response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String,dynamic>;
      if(data['meals']!= null) {
        featchList.addAll((data['meals'] as List)
            .map((item) => item['strCategory'] as String)
            .toList());
      }else {
        featchList = [];
        print('No meals found for categoriesList');
      }
      categoriesList.value = featchList;
    }
  }

  void printlist() {
    for (var item in favouriteController.myStringList) {
      print("list id");
      print(item);
    }
  }

  void toRecipeDetail(Meal meal) {
    Get.toNamed(Routers.recipesDetailRouter, arguments: {"GetMeal": meal});
  }

  void toSearch([String? search = '']) {
    Get.toNamed(Routers.searchRouter, arguments: {"search": search});
  }

  void categoriesToSearch([String? categories = '']) {
    Get.toNamed(Routers.searchRouter, arguments: {"categories" : categories});
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchRandomMeals();
  }
}
