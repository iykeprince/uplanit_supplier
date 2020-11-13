import 'package:uplanit_supplier/core/enums/view_state.dart';
import 'package:uplanit_supplier/core/models/category.dart';
import 'package:uplanit_supplier/core/models/post_category.dart';
import 'package:uplanit_supplier/core/services/authentication_service.dart';
import 'package:uplanit_supplier/core/services/business_profile_service.dart';
import 'package:uplanit_supplier/core/utils/locator.dart';
import 'package:uplanit_supplier/core/viewmodels/base_model.dart';

class SupplierCategoryModel extends BaseModel {
  AuthenticationService auth = locator<AuthenticationService>();
  BusinessProfileService _businessProfileService =
      locator<BusinessProfileService>();
  bool _loading = false;
  List<Category> _supplierCategories = List<Category>();
  List<Category> _selectedSupplierCategoryList = List<Category>();
  bool get loading => _loading;
  List<Category> get supplierCategories => _supplierCategories;
  List<Category> get selectedSupplierCategoryList =>
      _selectedSupplierCategoryList;

  void getCategories() async {
    _supplierCategories.clear();
    _loading = true;
    List<Category> categories =
        await _businessProfileService.getCategories(user: auth.user);
    _supplierCategories = categories;
    _loading = false;
    notifyListeners();
  }

  Future<List<Category>> updateSupplierCategory() async {
    String token = await auth.user.getIdToken();
    PostCategory postCategory = PostCategory(
      categories: List<String>.from(
          selectedSupplierCategoryList.map<String>((e) => e.id)).toList(),
    );
    return await _businessProfileService.updateSupplierCategory(
      postCategories: postCategory,
      token: token,
    );
  }

  void toggleSelected(int index) {
    Category category = _supplierCategories[index];
    category.selected = !category.selected;
    print('tapped: $category selected state: ${category.selected}');
    List<Category> list = _selectedSupplierCategoryList
        .where((element) => element.categoryId == category.categoryId)
        .toList();
    if (list.length == 0) {
      _selectedSupplierCategoryList.add(category);
    }
    notifyListeners();
  }
}
