import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uplanit_supplier/core/enums/view_state.dart';
import 'package:uplanit_supplier/core/models/base_profile.dart';
import 'package:uplanit_supplier/core/models/category.dart';
import 'package:uplanit_supplier/core/utils/locator.dart';
import 'package:uplanit_supplier/core/viewmodels/business_profile_model.dart';
import 'package:uplanit_supplier/ui/shared/custom_colors.dart';
import 'package:uplanit_supplier/ui/widgets/custom_progress_widget.dart';

import '../../base_view.dart';
import 'viewmodels/supplier_category_model.dart';

class SupplierCategoryDialog extends StatelessWidget {
  SupplierCategoryDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child:  Container(
          height: 540,
          padding: const EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 42,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Expanded(
                        child: SupplierCategoryView(),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlatButton(
                      child: Text('CANCEL'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    Consumer<SupplierCategoryModel>(
                      builder: (context, value, child) => FlatButton(
                        child: value.state == ViewState.Busy
                            ? CustomProgressWidget()
                            : Text(
                                'UPDATE'),
                        onPressed:
                            value.selectedSupplierCategoryList.length == 0
                                ? null
                                : () async {
                                    value.setState(ViewState.Busy);
                                    List<Category> eventTypes =
                                        await value.updateSupplierCategory();
                                    value.setState(ViewState.Idle);
                                    if (eventTypes.length > 0) {
                                      Navigator.pop(context);
                                    } else {
                                      print('An error has occurred');
                                    }
                                  },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

    );
  }
}

class SupplierCategoryView extends StatefulWidget {
  @override
  _SupplierCategoryViewState createState() => _SupplierCategoryViewState();
}

class _SupplierCategoryViewState extends State<SupplierCategoryView> {
  SupplierCategoryModel model;

  @override
  void initState() {
    model = Provider.of<SupplierCategoryModel>(context, listen: false);
    model.getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return model.loading
        ? CustomProgressWidget()
        : GridView.builder(
            shrinkWrap: true,
            itemCount: model.supplierCategories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) => _buildItem(
              context,
              index,
              model.supplierCategories,
            ),
          );
  }

  _buildItem(
    BuildContext context,
    int index,
    List<Category> supplierCategories,
  ) {
    Category category = supplierCategories[index];
    print('category: $category selected ${category.selected}');

    return InkWell(
      onTap: () {
        context.read<SupplierCategoryModel>().toggleSelected(index);
      },
      child: Opacity(
        opacity: category.selected ? 1 : .4,
        child: Container(
          width: 106,
          height: 108,
          decoration: BoxDecoration(
            color: CustomColor.uplanitBlue,
          ),
          child: Center(
            child: Text(
              category.name,
              style: GoogleFonts.workSans(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
