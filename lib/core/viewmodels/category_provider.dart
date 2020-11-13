import 'package:firebase_auth/firebase_auth.dart';
import 'package:uplanit_supplier/core/models/category.dart';
import 'package:uplanit_supplier/core/models/post_category.dart';
import 'package:uplanit_supplier/core/services/authentication_service.dart';
import 'package:uplanit_supplier/core/services/onboard_service.dart';
import 'package:uplanit_supplier/core/utils/locator.dart';
import 'package:uplanit_supplier/core/viewmodels/base_model.dart';

class CategoryProvider extends BaseModel {
  OnboardService onboardService = OnboardService();
  AuthenticationService auth = locator<AuthenticationService>();
  List<Category> _categoryList = [];
  List<Category> _selectedCategoryList = [];

  bool isCategoryLoading = false;

  List<Category> get categoryList => _categoryList;
  List<Category> get selectedCategoryList => _selectedCategoryList;

  void setCategoryList(List<Category> categories) {
    _categoryList = categories;

    notifyListeners();
  }

  void loadCategory() async {
    isCategoryLoading = true;
    _selectedCategoryList.clear();
    _categoryList.clear();
    List<Category> categories =
        await onboardService.getCategories(user: auth.user);

    isCategoryLoading = false;
    setCategoryList(categories);
  }

  Future<List<Category>> createCategory() async {
    String token = await auth.user.getIdToken();
    PostCategory postCategory = PostCategory(
        categories:
            List<String>.from(selectedCategoryList.map<String>((e) => e.id))
                .toList());
    return onboardService.createCategory(
      postCategories: postCategory,
      token: token,
    );
  }

  void toggleSelected(int index) {
    Category category = _categoryList[index];
    category.selected = !category.selected;

    List<Category> list = _selectedCategoryList
        .where((element) => element.categoryId == category.categoryId)
        .toList();

    if (category.selected && list.length <= 0) {
      _selectedCategoryList.add(category);
    } else {
      _selectedCategoryList.remove(category);
    }
    notifyListeners();
  }
}
