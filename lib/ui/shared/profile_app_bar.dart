import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uplanit_supplier/core/services/authentication_service.dart';
import 'package:uplanit_supplier/ui/shared/custom_colors.dart';

AppBar profileAppBar({
  @required String title,
  List<Widget> actions,
  Function onTapProfileIcon,
}) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    leading: Container(
      margin: const EdgeInsets.only(left: 16.0, top: 8.0,),
      width: 60,
      child: InkWell(
        onTap: onTapProfileIcon,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: AssetImage('assets/images/supplier.png'),
            ),
          ],
        ),
      ),
    ),
    title: Text(
      title,
      style: GoogleFonts.workSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: CustomColor.uplanitBlue,
      ),
    ),
    actions: actions != null ? actions.map((action) => action).toList() : [],
  );
}
