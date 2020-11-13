import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uplanit_supplier/core/enums/request_type.dart';
import 'package:uplanit_supplier/core/models/base_portfolio.dart';
import 'package:uplanit_supplier/core/models/portfolio.dart';
import 'package:uplanit_supplier/core/models/portfolio_response.dart';
import 'package:uplanit_supplier/core/repository/api_repository.dart';
import 'package:uplanit_supplier/core/utils/api_endpoint.dart';
import 'package:uplanit_supplier/core/utils/exception_util.dart';
import 'package:uplanit_supplier/core/utils/locator.dart';

import 'authentication_service.dart';

class PortfolioService {
  ApiRepository apiRepository = ApiRepository();

  Future<dynamic> getImages({String token}) async {
    print('token: $token');
    try {
      final response = await apiRepository.request(
        requestType: RequestType.GET,
        path: ApiEndpoint.GET_IMAGES,
        token: token,
      );
      print('response object: ${response.toString}');
      print('status: ${response.statusCode}');
      print('body: ${response.body}');
      if (response.statusCode == 200) {
        return basePortfolioFromJson(response.body);
      } else if (response.statusCode == 404) {
        return [];
      }
      return returnResponse(response);
    } catch (e) {
      print('Network error: ${e.toString()}');
      return [];
    }
  }

  //get file upload url
  Future<String> getFileUploadURL({
    @required User user,
    @required String dynamicURL,
  }) async {
    String token = await user.getIdToken();
    try {
      final response = await apiRepository.request(
        requestType: RequestType.GET,
        path: dynamicURL,
        token: token,
      );
      if (response.statusCode == 200) {
        return response.body;
      }
      return returnResponse(response);
    } catch (e) {
      print('Network error: ${e.message}');
      return null;
    }
  }

  //upload to s3
  Future<String> uploadFileToS3({
    @required String url,
    @required File file,
  }) async {
    try {
      final response = await apiRepository.requestFile(
        requestType: RequestType.UPLOAD_IMAGE,
        path: url,
        file: file,
      );
      return response;
    } catch (e) {
      print('s3 Network error: ${e.message}');
      return "";
    }
  }

  Future<PortfolioResponse> addImage(
      {String token, Portfolio portfolio}) async {
    print('portfolio: ${portfolioToJson(portfolio)}');
    try {
      final response = await apiRepository.request(
        requestType: RequestType.POST,
        path: ApiEndpoint.ADD_IMAGE,
        parameter: portfolioToJson(portfolio),
        token: token,
      );
      print('status code: ${response.statusCode}');
      print('body: ${response.body}');
      if (response.statusCode == 200) {
        print('body: ${response.body}');
        return portfolioResponseFromJson(response.body);
      }
      return returnResponse(response);
    } catch (e) {
      print('Network error: ${e.message}');
    }
  }
}
