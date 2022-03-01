import 'dart:core';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ship_organizer_app/entities/report.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ship_organizer_app/offline_queue/offline_enqueue_item.dart';
import 'package:ship_organizer_app/offline_queue/offline_enqueue_service.dart';
import 'package:ship_organizer_app/views/inventory/item.dart';

class ApiService {
  /// Ensures there can only be created one of the API service
  /// This makes it a singleton
  static final ApiService _apiService = ApiService._internal();

  factory ApiService() {
    return _apiService;
  }

  ApiService._internal();

  FlutterSecureStorage storage = FlutterSecureStorage();
  String baseUrl = "http://10.22.195.237:8080/";

  Dio dio = Dio();

  /// Validates the token which is currently in secure storage
  /// Returns false if token is invalid else it returns true
  Future<bool> isTokenValid() async {
    bool valid = false;
    try {
      String? token = await _getToken();
      dio.options.headers["Authorization"] = "Bearer $token";
      await dio.get(baseUrl + "api/user/check-role");
      valid = true;
    } on Exception catch (e) {
      valid = false;
    }
    return valid;
  }

  /// Gets token from secure storage on the device
  Future<String> _getToken() async {
    String? token = await storage.read(key: "jwt");
    token ??= "No Token";
    return token;
  }

  /// Makes a call to the server to try to log in
  /// Returns true if was able to log in else it returns false
  /// If able to log in then the token returned from the server
  /// is stored on the device in secure storage
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

  /// Signs a user out
  /// This removes the token from storage
  /// returns true if was able to delete token
  /// false otherwise
  Future<bool> signOut() async {
    bool success = false;

    try {
      await storage.delete(key: "jwt");
      success = true;
    } on Exception catch (_, e) {}

    return success;
  }

  /// Gets the list of departments a user has access to from the API
  /// Returns a list of available departments
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

  /// Uses an email, password and list of departments to register a new user
  /// The data is sent to the API where it is handled to create a new user
  Future<bool> registerUser(String email, String fullName, List<String> departments) async {
    bool success = false;

    var data = {'email': email, 'fullname': fullName, 'departments': departments};
    try {
      String? token = await _getToken();
      dio.options.headers["Authorization"] = "Bearer $token";
      await dio.post(baseUrl + "auth/register", data: data);
      success = true;
    } on Exception catch (e) {}

    return success;
  }

  /// Uses a users email to send them a verification code
  /// which can be used to set a password
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

  /// Verifies if the code that has been entered is correct
  /// Returns true if the code is valid otherwise it returns false
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

  /// Uses email verification code and password to set a new password for a user
  /// Returns true if successful false otherwise
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
  var token =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJuYW1lIjoiSm9oYW5uZXMgSm9zZWZzZW4iLCJpZCI6MzAsImV4cCI6MTY0NzkzODI1MSwiZW1haWwiOiJqb29oYWE5OUBnbWFpbC5jb20ifQ.0CmMwvQrmf2Lx-I8HPqtJfsJ-F87uNoideqMOdDNrDX5DII1C-1J14YUabdy-Tqmkrp9h0OAx0Cuua9BO0z1TA";

  ///Test connection to api server
  Future<int> testConnection() async {
    int code = 101;
    await dio.get(baseUrl + "actuator/health")
        .then((value) =>  value.statusCode != null ? code = value.statusCode! : code = 101)
        .onError((error, stackTrace) => code = 101);
    return code;
  }

  ///Gets all products from the backend server
  ///Returns a list of all the products
  Future<List<Item>> getItems() async {
    int? connectionCode = await testConnection();
    await _getToken().then((jwt) => token = jwt);
    dio.options.headers["Authorization"] = "Bearer $token";
    List<Item> items = [];
    if (connectionCode == 200) {
      var response = await dio.get(baseUrl + "api/product/inventory");
      if (response.statusCode == 200) {
        List<dynamic> products = List<dynamic>.from(response.data);
        String name = "";
        String number = "";
        String ean13 = "";
        int stock = 0;
        for (var product in products) {
          product.forEach((key, value) {
            switch (key) {
              case "barcode":
                ean13 = value;
                break;
              case "productName":
                name = value;
                break;
              case "productNumber":
                number = value;
                break;
              case "stock":
                stock = int.parse(value);
                break;
            }
          });
          items.add(Item(
              name: name, productNumber: number, ean13: ean13, amount: stock));
        }
      }
    }

    return items;
  }

  ///Gets all products for the recommended inventory report
  ///Returns list of all products that needs to be refilled
  Future<List<Item>> getRecommendedItems() async {
    int? connectionCode = await testConnection();
    dio.options.headers["Authorization"] = "Bearer $token";
    List<Item> items = [];

    if (connectionCode == 200) {
      var response = await dio.get(baseUrl + "api/product/RecommendedInventory");

      if (response.statusCode == 200) {
        List<dynamic> products = List<dynamic>.from(response.data);
        for (var product in products) {
          String name = "";
          String number = "";
          String ean13 = "";
          int stock = 0;
          product.forEach((key, value) {
            switch (key) {
              case "barcode":
                ean13 = value;
                break;
              case "productName":
                name = value;
                break;
              case "productNumber":
                number = value;
                break;
              case "stock":
                stock = int.parse(value);
                break;
            }
          });
          items.add(Item(
              name: name, productNumber: number, ean13: ean13, amount: stock));
        }
      }
    }

    return items;
  }

  /// Update stock for a specific product
  Future<void> updateStock(String productNumber, String username, int amount,
      double latitude, double longitude) async {
    int? connectionCode = await testConnection();

    dio.options.headers["Authorization"] = "Bearer $token";

    dynamic data = {
      "productNumber": productNumber,
      "username": username,
      "quantity": amount,
      "latitude": latitude,
      "longitude": longitude
    };

    if (connectionCode == 200) {
      await dio.post(baseUrl + "api/product/setNewStock", data: data);
    } else {
      print("Adding item to offline queue:");
      OfflineEnqueueItem queueItem = OfflineEnqueueItem(
          type: "UPDATE_STOCK",
          status: "PENDING",
        data: data
      );
      OfflineEnqueueService().addToQueue(queueItem);
    }
  }

}
