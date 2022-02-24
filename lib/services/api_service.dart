import 'dart:core';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ship_organizer_app/entities/report.dart';
import 'package:ship_organizer_app/views/inventory/item.dart';

class ApiService {
  final Dio dio = Dio();
  //String baseUrl = "http://127.0.0.1:8080/";
  String baseUrl = "http://172.20.10.2:8080/";

  var token =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJuYW1lIjoiU2ltb24gRHVnZ2FsIiwiaWQiOjMxLCJleHAiOjE2NDc1MDk4MzMsImVtYWlsIjoic2ltb25kdUBudG51Lm5vIn0.JO3XVtbhW7lNOWSKcWlnK8_o1zBvPxOmgfeDUHLbVdvs8w40mWqrUT6fkNM2D7iS9LXYbJUm8bC5ImARerkqPg";

  ///Test connection to api server
  Future<int?> testConnection() async {
    var testConnection = await dio.get(baseUrl + "actuator/health");
    return testConnection.statusCode;
  }

  ///Gets all products from the backend server
  ///Returns a list of all the products
  Future<List<Item>> getItems() async {
    int? connectionCode = await testConnection();
    dio.options.headers["Authorization"] = "Bearer $token";
    List<Item> items = [];
    if (connectionCode == 200) {
      var response = await dio.get(baseUrl + "product/inventory");
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

  /// Gets all the markers from the api
  /// returns a Map with LatLng as keys and lists of reports
  /// grouped on that LatLng as values
  Future<Map<LatLng, List<Report>>> getAllMarkers() async {
    var response = await dio.get(baseUrl + "reports/all-reports");
    return createReportsFromData(response);
  }

  /// Gets markers with same product name from the api
  /// returns a Map with LatLng as keys and lists of reports
  /// grouped on that LatLng as values
  Future<Map<LatLng, List<Report>>> getAllMarkersWithName(String name) async {
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

  ///Gets user rights. Checks if user has admin rights
  Future<String> getUserRights() async {
    dio.options.headers["Authorization"] = "Bearer $token";
    int? connectionCode = await testConnection();
    var response;
    if (connectionCode == 200){
       response = await dio.get(baseUrl + "api/user/check-role");
    }
    return response.data;
  }

  ///Gets user name
  Future<String> getUserName() async {
    dio.options.headers["Authorization"] = "Bearer $token";
    int? connectionCode = await testConnection();
    var response;
    if (connectionCode == 200){
      response = await dio.get(baseUrl + "api/user/check-role");
    }
    return response.data;
  }


  //Gets pending orders from the api based on department name


}
