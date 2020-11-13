import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uplanit_supplier/core/models/base_profile.dart';
import 'package:uplanit_supplier/core/services/authentication_service.dart';
import 'package:uplanit_supplier/core/viewmodels/business_profile_model.dart';
import 'package:uplanit_supplier/ui/shared/profile_app_bar.dart';
import 'package:uplanit_supplier/ui/views/base_view.dart';
import 'package:uplanit_supplier/ui/views/portfolio/portfolio.dart';

import 'address_information.dart';
import 'product_description.dart';
import 'profile_image.dart';
import 'contact_information.dart';
import 'work_hours.dart';

class BusinessProfile extends StatelessWidget {
  static const String ROUTE = '/business_profile/business_profile';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: profileAppBar(
          title: 'Business Profile',
          onTapProfileIcon: () =>
              context.read<AuthenticationService>().logout(),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pushNamed(
                context,
                PortfolioPage.ROUTE,
              ),
              child: Text(
                'Portfolio',
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            )
          ]),
      body: BaseView<BusinessProfileModel>(
        onModelReady: (model) => model.getBaseProfile(),
        builder: (context, model, child) => ListView(
          children: [
            Column(
              children: [
                ProfileImageView(),
                ProductDescriptionView(),
                AddressInformationView(),
                ContactView(),
                WorkHoursView(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}