import 'dart:core';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ship_organizer_app/entities/report.dart';
import 'package:ship_organizer_app/views/inventory/item.dart';

class ApiService {
  final Dio dio = Dio();
  String baseUrl = "http://172.20.10.2:8080/";
  var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJuYW1lIjoiU2ltb24gRHVnZ2FsIiwiaWQiOjMxLCJleHAiOjE2NDc1MDk4MzMsImVtYWlsIjoic2ltb25kdUBudG51Lm5vIn0.JO3XVtbhW7lNOWSKcWlnK8_o1zBvPxOmgfeDUHLbVdvs8w40mWqrUT6fkNM2D7iS9LXYbJUm8bC5ImARerkqPg";
  ///Gets all products from the backend server
  ///Returns a list of all the products
  Future<List<Item>> getItems() async {
    dio.options.headers["Authorization"] = "Bearer $token";
    var response = await dio.get(baseUrl + "product/inventory");
    List<Item> items = [];
    List<dynamic> products = List<dynamic>.from(response.data);
    for (var product in products) {
      String name = "";
      String number = "";
      String ean13 = "";
      int stock = 0;
      product.forEach((key,value) {
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
      items.add(Item(name:name,productNumber: number,ean13: ean13, amount: stock));

    }
    return items;
  }
  ///Gets all products for the recommended inventory report
  ///Returns list of all products that needs to be refilled
  Future<List<Item>> getRecommendedItems() async {
    dio.options.headers["Authorization"] = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJuYW1lIjoiSGFucyBMaW5kZ2FhcmQiLCJpZCI6MjgsImV4cCI6MTY0NzQyMzQ4NCwiZW1haWwiOiJoYW5zYWxAc3R1ZC5udG51Lm5vIn0.TWheVKzg80VL8uH_CxvuFReZOiepRoIyzcfRhmq8BgFuaX6C7d8B21BecGTqVA9Q8Osy1pHZDD0lZoc5kK2TGA";
    var response = await dio.get(baseUrl + "product/RecommendedInventory");
    List<Item> items = [];
    List<dynamic> products = List<dynamic>.from(response.data);
    for (var product in products) {
      String name = "";
      String number = "";
      String ean13 = "";
      int stock = 0;
      product.forEach((key,value) {
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
      items.add(Item(name:name,productNumber: number,ean13: ean13, amount: stock));

    }

    return items;
  }

  /// Update stock for a specific product
  Future<void> updateStock() async{
    dio.options.headers["Authorization"] = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJuYW1lIjoiSGFucyBMaW5kZ2FhcmQiLCJpZCI6MjgsImV4cCI6MTY0NzQyMzQ4NCwiZW1haWwiOiJoYW5zYWxAc3R1ZC5udG51Lm5vIn0.TWheVKzg80VL8uH_CxvuFReZOiepRoIyzcfRhmq8BgFuaX6C7d8B21BecGTqVA9Q8Osy1pHZDD0lZoc5kK2TGA";
    var response = await dio.get(baseUrl + "product/inventory");


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
