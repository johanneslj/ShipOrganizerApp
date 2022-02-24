import 'dart:core';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ship_organizer_app/entities/report.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  /// Ensures there can only be created one of the API service
  /// This makes it a singleton
  static final ApiService _apiService = ApiService._internal();

  factory ApiService() {
    return _apiService;
  }

  ApiService._internal();

  FlutterSecureStorage storage = FlutterSecureStorage();
  String baseUrl = "http://10.22.186.180:8080/";

  Dio dio = Dio();

  Future<bool> isTokenValid() async {
    bool valid = false;
    try {
      String? token = await storage.read(key: "jwt");
      if (token != null) {
        dio.options.headers["Authorization"] = "Bearer $token";
        var response = await dio.get(baseUrl + "api/user/check-role");
        valid = true;
      }
    } on Exception catch (_, e) {
      valid = false;
    }

    return valid;
  }

  Future<String?> _getToken() async {
    String? token = await storage.read(key: "jwt");
    token ??= "No Token";
    return token;
  }

  Future<bool> attemptToLogIn(String email, String password) async {
    bool success = false;

    var data = {'email': email, 'password': password};
    try {
      var response = await dio.post(baseUrl + "auth/login", data: data);
      if (response.data != null) {
        storage.write(key: "jwt", value: response.data);
        success = true;
      }
    } on Exception catch (_, e) {
      success = false;
    }
    return success;
  }

  Future<bool> signOut() async {
    bool success = false;

    try {
      await storage.delete(key: "jwt");
      success = true;
    } on Exception catch (_, e) {}

    return success;
  }

  Future<List<String>> getDepartments() async {
    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
    var response = await dio.get(baseUrl + "api/user/departments");
    List<Map<String, dynamic>> departmentsList = List<Map<String, dynamic>>.from(response.data);
    List<String> departments = [];
    for (var department in departmentsList) {
      departments.add(department["name"]);
    }
    storage.write(key: "departments", value: departments.toString());
    return departments;
  }

  Future<bool> registerUser(String email, String fullName, List<String> departments) async {
    bool success = false;

    var data = {'email': email, 'fullname': fullName, 'departments': departments};

    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
    var response = await dio.post(baseUrl + "auth/register", data: data);

    return success;
  }

  Future<bool> sendVerificationCode(String email) async {
    bool success = false;
    try {
      String? token = await _getToken();
      dio.options.headers["Authorization"] = "Bearer $token";
      await dio.get(baseUrl + "api/user/send-verification-code?email=" + email);
      success = true;
    } on Exception catch (e) {
      success = false;
    }
    return success;
  }

  Future<bool> verifyVerificationCode(String email, String verificationCode) async {
    bool success = false;

    try {
      String? token = await _getToken();
      if (token != null) {
        dio.options.headers["Authorization"] = "Bearer $token";
        await dio.get(baseUrl +
            "api/user/check-valid-verification-code?email=" +
            email +
            "&code=" +
            verificationCode);

        success = true;
      }
    } on DioError catch (e) {
      success = false;
    }

    return success;
  }

  Future<bool> setNewPassword(String email, String verificationCode, String password) async {
    bool success = false;

    var data = {'email': email, 'code': verificationCode, 'password': password};

    try {
      String? token = await _getToken();
      dio.options.headers["Authorization"] = "Bearer $token";
      await dio.post(baseUrl + "api/user/set-password", data: data);
      success = true;
      if (success) {
        storage.delete(key: "jwt");
      }
    } on DioError catch (e) {
      success = false;
    }

    return success;
  }

  /// Gets all the markers from the api
  /// returns a Map with LatLng as keys and lists of reports
  /// grouped on that LatLng as values
  Future<Map<LatLng, List<Report>>> getAllMarkers() async {
    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
    var response = await dio.get(
      baseUrl + "reports/all-reports",
    );
    return createReportsFromData(response);
  }

  /// Gets markers with same product name from the api
  /// returns a Map with LatLng as keys and lists of reports
  /// grouped on that LatLng as values
  Future<Map<LatLng, List<Report>>> getAllMarkersWithName(String name) async {
    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
    var response = await dio.get(baseUrl + "reports/reports-with-name=$name");
    return createReportsFromData(response);
  }

  /// Uses the response from the API to create a Map with
  /// LatLng as keys with lists of reports as values
  ///
  /// The reports are created from the data, added to a list
  /// and then lastly added to a map, based on if they should
  /// be grouped together
  Map<LatLng, List<Report>> createReportsFromData(var response) {
    Map<LatLng, List<Report>> reports = <LatLng, List<Report>>{};
    Map<String, dynamic> markers = Map<String, dynamic>.from(response.data);
    markers.forEach((key, value) {
      List<Report> reportsOnSameLatLng = <Report>[];
      for (var report in List<dynamic>.from(value)) {
        {
          /// A report is constructed using the factory pattern
          /// First an empty Report is created then each of its fields
          /// are set sequentially until all of them have a value
          Report reportFromData = Report();
          Map<String, dynamic>.from(report).forEach((identifier, reportFieldValue) {
            switch (identifier) {
              case "productName":
                reportFromData.setName(reportFieldValue);
                break;
              case "quantity":
                reportFromData.setQuantity(reportFieldValue);
                break;
              case "latitude":
                reportFromData.setLatitude(reportFieldValue);
                break;
              case "longitude":
                reportFromData.setLongitude(reportFieldValue);
                break;
              case "registrationDate":
                reportFromData.setDate(DateTime.parse(reportFieldValue.split(".")[0]));
                break;
              case "fullName":
                reportFromData.setUserName(reportFieldValue);
                break;
            }
          });
          reportsOnSameLatLng.add(reportFromData);
        }
        double latitude = double.parse(key.split(", ")[0]);
        double longitude = double.parse(key.split(", ")[1]);
        reports.putIfAbsent(LatLng(latitude, longitude), () => reportsOnSameLatLng);
      }
    });
    return reports;
  }
}
