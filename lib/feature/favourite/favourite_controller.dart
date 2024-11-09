import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:recipes/core/routing/routers.dart';
import 'package:recipes/models/Meal.dart';

class FavouriteController extends GetxController {
  RxList<String> myStringList = <String>[].obs; // Chỉ lưu ID
  RxBool isLoading = false.obs;
  var favouriteList = <Meal>[].obs; // Danh sách các món ăn yêu thích

  // Hàm để tải danh sách từ Hive vào `myStringList`
  void loadFavourites() {
    var box = Hive.box('favouritesBox');
    myStringList.value =
        List<String>.from(box.get('favouriteList', defaultValue: []));
    fetchFavouriteMeals(); // Lấy thông tin chi tiết các món ăn yêu thích
  }

  // Hàm để thêm một mục vào danh sách và lưu vào Hive
  Future<void> addFavourite(String itemId) async {
    if (!myStringList.contains(itemId)) {
      myStringList.add(itemId);
      saveFavourites();
      await fetchAndSaveMealDetails(
          itemId); // Gọi API để lấy thông tin chi tiết
    }
  }

  // Hàm để xóa một mục từ danh sách và cập nhật Hive
  void removeFavourite(String itemId) {
    myStringList.remove(itemId);
    saveFavourites();
    favouriteList.removeWhere(
        (meal) => meal.idMeal == itemId); // Xóa món ăn khỏi danh sách hiển thị
  }

  void removeAllFavourite() {
    myStringList.clear();
    saveFavourites();
    favouriteList.clear();
  }

  // Lưu danh sách hiện tại vào Hive
  void saveFavourites() {
    var box = Hive.box('favouritesBox');
    box.put('favouriteList', myStringList);
  }

  // Gọi API để lấy thông tin chi tiết món ăn yêu thích và lưu vào danh sách
  Future<void> fetchAndSaveMealDetails(String itemId) async {
    final response = await http.get(Uri.parse(
        'http://www.themealdb.com/api/json/v1/1/lookup.php?i=$itemId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['meals'] != null && data['meals'].isNotEmpty) {
        Meal meal = Meal.fromJson(data['meals'][0]);
        favouriteList.add(meal); // Thêm vào danh sách các món ăn yêu thích
      }
    }
  }

  // danh sách các món ăn yêu thích từ API theo Id Hive
  Future<void> fetchFavouriteMeals() async {
    isLoading(true);
    List<Meal> fetchedMeals = [];
    for (var id in myStringList) {
      final response = await http.get(
          Uri.parse('http://www.themealdb.com/api/json/v1/1/lookup.php?i=$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          fetchedMeals.add(Meal.fromJson(data['meals'][0]));
        }
      }
    }
    favouriteList.assignAll(fetchedMeals);
    isLoading(false);
  }

  void toRecipeDatail(Meal meal) {
    Get.toNamed(Routers.recipesDetailRouter, arguments: {"GetMeal": meal});
  }

  @override
  void onInit() {
    super.onInit();
    loadFavourites(); // Tải danh sách yêu thích khi khởi tạo
  }
}
