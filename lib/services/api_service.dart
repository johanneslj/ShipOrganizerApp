import 'dart:core';
import 'package:dio/dio.dart';
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
  String token =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJuYW1lIjoiSGFucyBMaW5kZ2FhcmQiLCJpZCI6MjgsImV4cCI6MTY0NzQyMzQ4NCwiZW1haWwiOiJoYW5zYWxAc3R1ZC5udG51Lm5vIn0.TWheVKzg80VL8uH_CxvuFReZOiepRoIyzcfRhmq8BgFuaX6C7d8B21BecGTqVA9Q8Osy1pHZDD0lZoc5kK2TGA";
  String baseUrl = "http://10.22.186.180:8080/";

  Dio dio = Dio();


  Future<bool> isTokenValid() async{
    bool valid = false;

    String? tokenName = await storage.read(key: "jwt");
    if(tokenName != null) {
        valid = true;
    }

    return valid;
  }

  /// Gets all the markers from the api
  /// returns a Map with LatLng as keys and lists of reports
  /// grouped on that LatLng as values
  Future<Map<LatLng, List<Report>>> getAllMarkers() async {
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
