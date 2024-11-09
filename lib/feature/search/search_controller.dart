import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:recipes/feature/favourite/favourite_controller.dart';
import 'package:recipes/models/Meal.dart';
import '../../core/routing/routers.dart';

class SearchMealsController extends GetxController {
  final String search = Get.arguments['search'] ?? '';
  final String categories = Get.arguments['categories'] ?? '';
  var mealsList = <Meal>[].obs;
  var listId = <String>[].obs;
  RxBool isloading = false.obs;
  FavouriteController favouriteController = Get.find<FavouriteController>();

  Future<void> fetchSearch() async {
    if (search.isEmpty) return; // Tránh gọi API nếu search trống

    try {
      print('Kiểm tra search $search');
      isloading.value = true;
      List<Meal> fetchMeals = [];
      final response = await http.get(
          Uri.parse('http://www.themealdb.com/api/json/v1/1/search.php?s=$search'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['meals'] != null) {
          fetchMeals.addAll((data['meals'] as List)
              .map((meal) => Meal.fromJson(meal))
              .toList());
        } else {
          print('No meals found for search: $search');
        }
      }
      mealsList.value = fetchMeals;
    } finally {
      isloading.value = false;
    }
  }

  Future<void> fetchIdCategories() async {
    isloading.value = true;
    if (categories.isEmpty) return; // Tránh gọi API nếu categories trống

    try {
      List<String> listIdMeals = [];

      final responseId = await http.get(
        Uri.parse("http://www.themealdb.com/api/json/v1/1/filter.php?c=$categories"),
      );

      // Kiểm tra nếu API trả về thành công
      if (responseId.statusCode == 200) {
        print("Response body: ${responseId.body}"); // In ra để kiểm tra JSON

        final dataId = json.decode(responseId.body) as Map<String, dynamic>;

        // Kiểm tra và chuyển đổi danh sách `meals`
        if (dataId.containsKey('meals') && dataId['meals'] != null) {
          listIdMeals = (dataId['meals'] as List)
              .map((meal) => meal['idMeal'] as String)
              .toList();
        } else {
          print("No meals found for category: $categories");
        }
      } else {
        print("Failed to load data. Status code: ${responseId.statusCode}");
      }

      listId.value = listIdMeals;

    } catch (e) {
      print("Error: $e");
    } finally {
      print("Fetching completed");
    }
  }



  Future<void> fetchCategories() async {
    if(listId.isEmpty){
      print("null nha $listId");
      return;
    }
    List<Meal> listMeal = [];
    try {
      for (var id in listId) {
        final response = await http.get(
            Uri.parse("https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id"));

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          if (data['meals'] != null) {
            listMeal.add(Meal.fromJson(data['meals'][0]));
          }
        }
      }
      mealsList.addAll(listMeal);
    } finally {
      isloading(false);
    }
  }


  void prints() {
    for (var item in listId) {
      print("id đang null nah anha $item");
    }
  }

  void toRecipeDetail(Meal meal) {
    Get.toNamed(Routers.recipesDetailRouter, arguments: {"GetMeal": meal});
  }

  @override
  void onInit() async{
    super.onInit();
    if (search.isNotEmpty) {
      await fetchSearch();
    }
    if (categories.isNotEmpty) {
      await fetchIdCategories();
      await fetchCategories();
    }

    prints();
  }
}
