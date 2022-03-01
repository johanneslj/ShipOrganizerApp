import 'dart:core';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ship_organizer_app/entities/Order.dart';
import 'package:ship_organizer_app/entities/report.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ship_organizer_app/entities/user.dart';
import 'package:ship_organizer_app/views/inventory/item.dart';

class ApiService {
  /// Ensures there can only be created one of the API service
  /// This makes it a singleton
  static final ApiService _apiService = ApiService._internal();
  late BuildContext buildContext;

  factory ApiService(BuildContext? context) {
    if (context != null) {
      _apiService.buildContext = context;
    }

    return _apiService;
  }

  ApiService._internal();

  FlutterSecureStorage storage = FlutterSecureStorage();
  String baseUrl = "http://10.22.186.180:8080/";

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
  Future<String?> _getToken() async {
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
    if(departments.length == 1) {
      storage.write(key: "activeDepartment", value: departments[0]);
    }
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

  Future<List<User>> getAllUsers() async {
    List<User> users = [];

    try {
      String? token = await _getToken();
      dio.options.headers["Authorization"] = "Bearer $token";
      var response = await dio.get(baseUrl + "api/user/all-users");

      List<Map<String, dynamic>> usersListMap = List<Map<String, dynamic>>.from(response.data);
      for (Map<String, dynamic> user in usersListMap) {
        User createdUser = User(name: user["name"], email: user["email"], departments: ["Bridge"]);
        users.add(createdUser);
      }
    } catch (e) {
      if(e is DioError) {
        print(e.response!.statusCode);
      }
      users = [User(name: "Something", email: "Happened..", departments: [])];
    }

    return users;
  }

  Future<bool> editUser(String email, String fullName, List<String> departments) async {
    bool success = false;

//TODO Make this interact with backend :)

    return success;
  }

  Future<bool> deleteUser(String email) async {
    bool success;
    try {
      String? token = await _getToken();
      dio.options.headers["Authorization"] = "Bearer $token";
      var data = {"username": email};
      await dio.delete(baseUrl + "api/user/delete-user", data: data);
      success = true;
    } on Exception catch (e) {
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
          Map<String, dynamic>.from(report)
              .forEach((identifier, reportFieldValue) {
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
                reportFromData
                    .setDate(DateTime.parse(reportFieldValue.split(".")[0]));
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
        reports.putIfAbsent(
            LatLng(latitude, longitude), () => reportsOnSameLatLng);
      }
    });
    return reports;
  }
  var token =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJuYW1lIjoiU2ltb24gRHVnZ2FsIiwiaWQiOjMxLCJleHAiOjE2NDc1MDk4MzMsImVtYWlsIjoic2ltb25kdUBudG51Lm5vIn0.JO3XVtbhW7lNOWSKcWlnK8_o1zBvPxOmgfeDUHLbVdvs8w40mWqrUT6fkNM2D7iS9LXYbJUm8bC5ImARerkqPg";

  ///Test connection to api server
  Future<int?> testConnection() async {
    var testConnection = await dio.get(baseUrl + "actuator/health");
    return testConnection.statusCode;
  }

  ///Gets all products from the backend server
  ///Returns a list of all the products
  Future<List<Item>> getItems(String department) async {
    String? token = await _getToken();
    int? connectionCode = await testConnection();
    dio.options.headers["Authorization"] = "Bearer $token";
    List<Item> items = [];
    if (connectionCode == 200) {
      var response =  await dio.post(baseUrl + "product/inventory", data: {
        "department": department
      });
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
    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
    List<Item> items = [];

    if (connectionCode == 200) {
      var response = await dio.get(baseUrl + "product/RecommendedInventory");

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
  Future<void> updateStock(String productnumber, String username, int amount,
      double latitude, double longitude) async {
    int? connectionCode = await testConnection();

    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";

    if (connectionCode == 200) {
      await dio.post(baseUrl + "product/setNewStock", data: {
        "productnumber": productnumber,
        "username": username,
        "quantity": amount,
        "latitude": latitude,
        "longitude": longitude
      });
    }
  }

  /// Forces a user to be logged out
  /// Is only called when the token is no longer valid
  void forceLogOut() {
    Navigator.pushNamedAndRemoveUntil(buildContext, "/", (route) => false);
  }
  ///Gets user rights. Checks if user has admin rights
  Future<String> getUserRights() async {
    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
    int? connectionCode = await testConnection();
    var response;
    if (connectionCode == 200) {
      response = await dio.get(baseUrl + "api/user/check-role");
    }
    return response.data;
  }

  ///Gets user name
  Future<String> getUserName() async {
    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
    int? connectionCode = await testConnection();
    var response;
    if (connectionCode == 200) {
      response = await dio.get(baseUrl + "api/user/name");
    }
    return response.data;
  }
  /// Gets pending order from api.
  /// Returns a list of orders
  Future<List<Order>> getPendingOrder() async {
    int? connectionCode = await testConnection();
    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
    List<Order> pendingOrders = [];
    var response;
    if (connectionCode == 200) {
      response = await dio.get(baseUrl + "orders/admin/pending");
      if (response.statusCode == 200) {
        List<dynamic> orders = List<dynamic>.from(response.data);
        for (var order in orders) {
          String imageName = "";
          String department = "";
          order.forEach((key, value) {
            switch (key) {
              case "imagename":
                imageName = value;
                break;
              case "departmentName":
                department = value;
                break;
            }
          });
          pendingOrders
              .add(Order(imagename: imageName, department: department));
        }
      }
    }
    return pendingOrders;
  }
  /// Gets users orders to confirm from api.
  /// Returns a list of orders
  Future<List<Order>> getUserConfirmedOrders() async {
    int? connectionCode = await testConnection();
    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
    List<Order> confirmedOrders = [];
    var response;
    if (connectionCode == 200) {
      response = await dio.post(baseUrl + "orders/user/pending", data: {
        "department": await getActiveDepartment()
      });
      if (response.statusCode == 200) {
        List<dynamic> orders = List<dynamic>.from(response.data);
        for (var order in orders) {
          String imageName = "";
          String department = "";
          order.forEach((key, value) {
            switch (key) {
              case "imagename":
                imageName = value;
                break;
              case "departmentName":
                department = value;
                break;
            }
          });
          confirmedOrders
              .add(Order(imagename: imageName, department: department));
        }
      }
    }
    return confirmedOrders;
  }

  /// Gets admin confirmed order from api.
  /// Returns a list of orders
  Future<List<Order>> getAdminConfirmedOrders() async {
    int? connectionCode = await testConnection();
    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
    List<Order> confirmedOrders = [];
    var response;
    if (connectionCode == 200) {
      response = await dio.get(baseUrl + "orders/confirmed");

      if (response.statusCode == 200) {
        List<dynamic> orders = List<dynamic>.from(response.data);
        for (var order in orders) {
          String imageName = "";
          String department = "";
          order.forEach((key, value) {
            switch (key) {
              case "imagename":
                imageName = value;
                break;
              case "departmentName":
                department = value;
                break;
            }
          });
          confirmedOrders
              .add(Order(imagename: imageName, department: department));
        }
      }
    }
    return confirmedOrders;
  }

  /// Update order from pending to confirmed for a specific order
  Future<void> updateOrder(String imageName, String department) async {
    int? connectionCode = await testConnection();
    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
    if (connectionCode == 200) {
      await dio.post(baseUrl + "orders/update", data: {
        "imageName": imageName,
        "department": department
      });
    }
  }

  ///Send order to api.
  Future<void> sendOrder(String imageName, String department) async {
    int? connectionCode = await testConnection();
    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
    if (connectionCode == 200) {
      await dio.post(baseUrl + "orders/new", data: {
        "imageName": imageName,
        "department": department
      });
    }
  }

  Future<void> setActiveDepartment(String department) async {
    await storage.write(key: "activeDepartment", value: department);
  }

  Future<String> getActiveDepartment() async {
    String? activeDepartment = await storage.read(key: "activeDepartment");
    if(activeDepartment == null){
      return "";
    }
    else {
      return activeDepartment;
    }
  }


}
