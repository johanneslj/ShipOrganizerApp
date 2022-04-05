import 'dart:convert';
import 'dart:core';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ship_organizer_app/entities/Order.dart';
import 'package:ship_organizer_app/entities/report.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ship_organizer_app/entities/user.dart';
import 'package:ship_organizer_app/offline_queue/offline_enqueue_service.dart';
import 'package:ship_organizer_app/views/inventory/item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ApiService {
  static final ApiService _apiService = ApiService._internal();
  late BuildContext buildContext;
  FlutterSecureStorage storage = const FlutterSecureStorage();
  Dio dio = Dio();
  String baseUrl = "http://10.22.186.180:8080/";

  //String baseUrl = "http://10.22.195.237:8080/";
  late DateTime lastUpdatedDate = DateTime(1900);

  ApiService._internal();

  factory ApiService(BuildContext? context) {
    if (context != null) {
      _apiService.buildContext = context;
    }
    return _apiService;
  }

  static ApiService getInstance() {
    return _apiService;
  }

  void setContext(BuildContext context) {
    buildContext = context;
  }

  ///Test connection to api server
  Future<int> testConnection() async {
    int code = 101;
    try {
      await dio.get(baseUrl + "connection").then((value) =>
          value.statusCode != null ? code = value.statusCode! : null);
    } on DioError catch (e) {
      return 101;
    }
    return code;
  }

  // Setts Authorization token for the api call
  Future<void> _setBearerForAuthHeader() async {
    String? token = await _getToken();
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  List<String> _decodeListFromString(String string) {
    List<String> list = [];
    if (string.startsWith("[")) {
      string = string.replaceFirst("[", "");
    }
    if (string.endsWith("]")) {
      string = string.replaceFirst("]", "", string.length - 1);
    }
    string = string.replaceAll(", ", ",");
    list = string.split(",");
    return list;
  }

  /// Stores token, full name of user and the username into the local storage
  bool _storeUserDataFromResponseAndGetSuccess(Response<dynamic> response) {
    if (response.data != null) {
      storage.write(key: "jwt", value: response.data["token"]);
      storage.write(key: "name", value: response.data["fullname"]);
      storage.write(key: "username", value: response.data["email"]);
      return true;
    } else {
      return false;
    }
  }

  //#region Region User

  /// Uses an email, password and list of departments to register a new user
  /// The data is sent to the API where it is handled to create a new user
  Future<bool> registerUser(
      String email, String fullName, List<String> departments) async {
    bool success = false;

    var data = {
      'email': email,
      'fullname': fullName,
      'departments': departments
    };
    try {
      await _setBearerForAuthHeader();
      await dio.post(baseUrl + "auth/register", data: data);
      success = true;
    } on DioError catch (e) {
      _handleRegistrationDioError(e);
    }
    return success;
  }

  /// Uses a users email to send them a verification code
  /// which can be used to set a password
  Future<bool> sendVerificationCode(String email) async {
    bool success = false;
    try {
      await _setBearerForAuthHeader();
      await dio.get(baseUrl + "api/user/send-verification-code?email=" + email);
      success = true;
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.unableToSendCode);
      success = false;
    }
    return success;
  }

  /// Verifies if the code that has been entered is correct
  /// Returns true if the code is valid otherwise it returns false
  Future<bool> verifyVerificationCode(
      String email, String verificationCode) async {
    bool success = false;
    try {
      if (null != await _getToken()) {
        success = await _verifyCodeAndGetSuccess(email, verificationCode);
      }
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.failedToConfirmCode);
      success = false;
    }
    return success;
  }

  /// Uses email verification code and password to set a new password for a user
  /// Returns true if successful false otherwise
  /// If an error is received from the server a error toast is shown to the
  /// user depending on the error code received
  Future<bool> setNewPassword(
      String email, String verificationCode, String password) async {
    bool success = false;
    var data = {'email': email, 'code': verificationCode, 'password': password};
    try {
      await _setBearerForAuthHeader();
      Response response =
          await dio.post(baseUrl + "api/user/set-password", data: data);
      success = response.statusCode == 200;
      if (success) {
        storage.delete(key: "jwt");
      }
    } on DioError catch (e) {
      _handleNewPasswordDioError(e);
      success = false;
    }
    return success;
  }

  /// Gets all the users from the server
  /// Returns a list of users
  Future<List<User>> getAllUsers() async {
    List<User> users = [];
    try {
      await _setBearerForAuthHeader();
      users = await _getAllUsersFromApi();
    } on DioError {
      _showErrorToast(AppLocalizations.of(buildContext)!.somethingWentWrong);
      users = [User(name: "Unable to ", email: "get users", departments: [])];
    }
    return users;
  }

  /// Edits a users different details,
  /// An admin can send in to change another users email,
  /// full name, and which departments they have access to
  Future<bool> editUser(String? oldEmail, String email, String fullName,
      List<String> departments) async {
    bool success = false;
    try {
      await _setBearerForAuthHeader();
      var data = {
        "name": fullName,
        "oldEmail": oldEmail,
        "newEmail": email,
        "departments": departments
      };
      Response response =
          await dio.post(baseUrl + "api/user/edit-user", data: data);
      success = response.statusCode == 220;
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.somethingWentWrong);
    }
    return success;
  }

  /// Takes the given email and sends a delete request
  /// to the server, this deletes the user with that email
  /// from the database
  Future<bool> deleteUser(String email) async {
    bool success;
    try {
      await _setBearerForAuthHeader();
      var data = {"username": email};
      await dio.delete(baseUrl + "api/user/delete-user", data: data);
      success = true;
    } on DioError catch (e) {
      if (e.response!.statusCode == 403) {
        _showErrorToast(
            AppLocalizations.of(buildContext)!.notAuthorizedToDeleteUser);
        forceLogOut();
      } else {
        _showErrorToast(AppLocalizations.of(buildContext)!.deleteFailed);
      }
      success = false;
    }
    return success;
  }

  void _handleRegistrationDioError(DioError e) {
    switch (e.response!.statusCode) {
      case 403:
        _showErrorToast(
            AppLocalizations.of(buildContext)!.notAllowedToCreateUser);
        forceLogOut();
        break;
      case 409:
        _showErrorToast(AppLocalizations.of(buildContext)!.userAlreadyExists);
        break;
      case 400:
        _showErrorToast(AppLocalizations.of(buildContext)!.badRequest);
        break;
      case 422:
        _showErrorToast(AppLocalizations.of(buildContext)!.invalidEmail);
        break;
    }
  }

  void _handleNewPasswordDioError(DioError e) {
    switch (e.response!.statusCode) {
      case 304:
        _showErrorToast(
            AppLocalizations.of(buildContext)!.couldNotChangePassword);
        break;
      case 400:
        _showErrorToast(AppLocalizations.of(buildContext)!.badRequest);
        break;
    }
  }

  ///Gets user rights. Checks if user has admin rights
  Future<String> getUserRights() async {
    String rights = "USER";
    try {
      await _setBearerForAuthHeader();
      int? connectionCode = await testConnection();
      if (connectionCode == 200) {
        var response = await dio.get(baseUrl + "api/user/check-role");
        rights = response.data;
        storage.write(key: "userRights", value: rights);
      }
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.somethingWentWrong);
    }
    return rights;
  }

  ///Gets user name
  Future<void> getUserName() async {
    await _setBearerForAuthHeader();
    await writeNameToStorage();
  }

  Future<void> writeNameToStorage() async {
    String name;
    if (200 == await testConnection()) {
      Response response = await dio.get(baseUrl + "api/user/name");
      name = response.data;
    } else {
      name = "";
    }
    storage.write(key: "name", value: name);
  }

  Future<List<User>> _getAllUsersFromApi() async {
    List<User> users = [];
    var response = await dio.get(baseUrl + "api/user/all-users");
    List<Map<String, dynamic>> usersListMap =
        List<Map<String, dynamic>>.from(response.data);
    for (Map<String, dynamic> user in usersListMap) {
      User createdUser = User(
          name: user["name"],
          email: user["email"],
          departments:
              List.of(user["departments"]).map((e) => e.toString()).toList());
      users.add(createdUser);
    }
    return users;
  }

  Future<bool> _verifyCodeAndGetSuccess(
      String email, String verificationCode) async {
    _setBearerForAuthHeader();
    var data = {"email": email, "code": verificationCode};
    Response response = await dio
        .post(baseUrl + "api/user/check-valid-verification-code", data: data);
    print(response);
    return response.statusCode == 200;
  }

  //#region Region Login/Logout

  /// Gets token from secure storage on the device
  Future<String?> _getToken() async {
    String? token;
    try {
      token = await storage.read(key: "jwt");
      token ??= "No Token";
    } catch (e) {
      token = "No Token";
    }
    return token;
  }

  /// Validates the token which is currently in secure storage
  /// Returns false if token is invalid else it returns true
  Future<bool> isTokenValid() async {
    bool valid = false;
    try {
      await _setBearerForAuthHeader();
      await dio.get(baseUrl + "api/user/check-role");
      valid = true;
    } catch (e) {
      valid = false;
    }
    return valid;
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
      success = _storeUserDataFromResponseAndGetSuccess(response);
    } catch (e) {
      success = false;
    }
    return success;
  }

  Future<bool> checkThatCorrectInfoIsWritten() async {
    try {
      if (await storage.containsKey(key: "userRights") ||
          await storage.containsKey(key: "departments")) {
        return false;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  /// Signs a user out
  /// This removes everything stored in storage
  /// returns true if was able to delete everything
  /// false otherwise
  Future<bool> signOut() async {
    bool success = false;
    try {
      await storage.deleteAll();
      success = true;
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.couldntLogOut);
    }
    return success;
  }

  /// Gets the list of departments a user has access to from the API
  /// Returns a list of available departments
  Future<List<String>> getDepartments() async {
    if ((await storage.read(key: "userRights")) == null) {
      await getUserRights();
    }

    List<String> storedDepartments = await _getStoredDepartments();
    if (storedDepartments.isNotEmpty) {
      return storedDepartments;
    }
    await _setBearerForAuthHeader();
    Response response;
    String? admin = await storage.read(key: "userRights");
    if (admin!.contains("ADMIN")) {
      response = await dio.get(baseUrl + "api/department/get-all");
    } else {
      response = await dio.get(baseUrl + "api/user/departments");
    }
    List<String> departments = _getDepartmentsFromResponse(response);
    storage.write(key: "departments", value: departments.toString());
    if (departments.length == 1) {
      storage.write(key: "activeDepartment", value: departments[0]);
    }
    return departments;
  }

  Future<List<String>> _getStoredDepartments() async {
    List<String> departments = [];
    if (await storage.containsKey(key: "departments")) {
      await storage
          .read(key: "departments")
          .then((value) => departments = _decodeListFromString(value!));
    }
    return departments;
  }

  /// Forces a user to be logged out
  /// Is only called when the token is no longer valid
  void forceLogOut() {
    storage.deleteAll();
    Navigator.pushNamedAndRemoveUntil(buildContext, "/", (route) => false);
  }

  //#endregion

  //#endregion

  //#region Region Markers

  /// Gets all the markers from the api
  /// returns a Map with LatLng as keys and lists of reports
  /// grouped on that LatLng as values
  Future<Map<LatLng, List<Report>>> getAllMarkers() async {
    String? token = await _getToken();
    Map<LatLng, List<Report>> mapMarkers;
    String department = await getActiveDepartment();
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      var response = await dio.get(
        baseUrl + "reports/all-reports=$department",
      );
      mapMarkers = _createReportsFromData(response);
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.failedToGetMarkers);
      mapMarkers = {
        const LatLng(0, 0): [Report()]
      };
    }
    return mapMarkers;
  }

  /// Gets markers with same product name from the api
  /// returns a Map with LatLng as keys and lists of reports
  /// grouped on that LatLng as values
  Future<Map<LatLng, List<Report>>> getAllMarkersWithName(String name) async {
    String? token = await _getToken();
    Map<LatLng, List<Report>> mapMarkers;
    String department = await getActiveDepartment();
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      var response = await dio
          .get(baseUrl + "reports/reports-with-name=$name-dep=$department");
      mapMarkers = _createReportsFromData(response);
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.failedToGetMarkers);
      mapMarkers = {
        const LatLng(0, 0): [Report()]
      };
    }
    return mapMarkers;
  }

  /// Uses the response from the API to create a Map with
  /// LatLng as keys with lists of reports as values
  ///
  /// The reports are created from the data, added to a list
  /// and then lastly added to a map, based on if they should
  /// be grouped together
  Map<LatLng, List<Report>> _createReportsFromData(var response) {
    Map<LatLng, List<Report>> reports = <LatLng, List<Report>>{};
    Map<String, dynamic> markers = Map<String, dynamic>.from(response.data);
    markers.forEach((key, value) {
      List<Report> reportsOnSameLatLng = <Report>[];
      for (var report in List<dynamic>.from(value)) {
        {
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

  //#endregion

  //#region Region Products

  /// Creates a new product which can be added to the backend
  Future<bool> createNewProduct(String productName, String productNumber,
      String desiredStock, String stock, String barcode) async {
    bool success = false;
    try {
      await _setBearerForAuthHeader();
      var data = {
        "productName": productName,
        "productNumber": productNumber,
        "desiredStock": desiredStock,
        "stock": stock,
        "barcode": barcode,
        "department": await getActiveDepartment(),
        "dateTime": DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now())
      };
      var response =
          await dio.post(baseUrl + "api/product/new-product", data: data);
      if (response.statusCode == 200) {
        success = true;
      }
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.somethingWentWrong);
    }
    return success;
  }

  Future<bool> editProduct(String productName, String productNumber,
      String desiredStock, String barcode) async {
    bool success = false;
    try {
      await _setBearerForAuthHeader();
      var data = {
        "productName": productName,
        "productNumber": productNumber,
        "desiredStock": desiredStock,
        "barcode": barcode,
        "department": await getActiveDepartment(),
        "dateTime": DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now())
      };
      var response =
          await dio.post(baseUrl + "api/product/edit-product", data: data);
      if (response.statusCode == 200) {
        var localStorage = await storage.read(key: "items");
        _updateStoreAndGetItems(localStorage, await getActiveDepartment());
        success = true;
      }
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.somethingWentWrong);
    }
    return success;
  }

  /// Deletes a product using the product number
  /// Returns true if successful else it returns false
  Future<bool> deleteProduct(String productNumber) async {
    bool success = false;

    try {
      await _setBearerForAuthHeader();

      var data = {"productNumber": productNumber};
      var response =
          await dio.post(baseUrl + "api/product/delete-product", data: data);
      if (response.statusCode == 200) {
        var localStorage = await storage.read(key: "items");
        List<Item> items = await _getItemsFromStorage(localStorage);
        int i = 0;
        while (i < items.length) {
          if (items[i].productNumber == productNumber) {
            items.removeAt(items.indexOf(items[i]));
          }
          i += 1;
        }
        await storage.write(key: "items", value: jsonEncode(items));
        success = true;
      }
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.deleteProductFailed);
    }

    return success;
  }

  //OLD
  Future<List<Item>> getAllItems() async {
    List<Item> items = [];
    try {
      await _setBearerForAuthHeader();
      String department = await getActiveDepartment();
      Response response = await dio.post(baseUrl + "api/product/get-inventory",
          data: {"department": department});
      if (response.statusCode == 200) {
        items = _getItemsFromResponse(response);
      }
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.somethingWentWrong);
    }
    return items;
  }

  ///Gets all products from the backend server
  ///Returns a list of all the products
  Future<List<Item>> getItems(String department) async {
    List<Item> updatedAllItems = [];
    var localStorage = await storage.read(key: "items");
    try {
      _setBearerForAuthHeader();
      if (200 == await testConnection()) {
        updatedAllItems =
            await _updateStoreAndGetItems(localStorage, department);
      } else {
        updatedAllItems = await _getItemsFromStorage(localStorage);
      }
    } on Exception {
      _showErrorToast(AppLocalizations.of(buildContext)!.somethingWentWrong);
    }
    updatedAllItems.sort((itemA, itemB) => itemA.productName.compareTo(itemB.productName));
    return updatedAllItems;
  }

  ///Gets all products for the recommended inventory report
  ///Returns list of all products that needs to be refilled
  Future<List<Item>> getRecommendedItems(String department) async {
    int? connectionCode = await testConnection();
    await _setBearerForAuthHeader();
    List<Item> items = [];
    try {
      if (connectionCode == 200) {
        var response = await dio.post(
            baseUrl + "api/product/get-recommended-inventory",
            data: {"department": department});
        if (response.statusCode == 200) {
          items = _getItemsFromResponse(response);
        }
      }
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.somethingWentWrong);
    }
    return items;
  }

  Future<bool> sendMissingInventory(
      List<Item> items, List<String> emailAddresses) async {
    await _setBearerForAuthHeader();
    bool success = false;

    var data = {"items": items, "receivers": emailAddresses};
    try {
      var response =
          await dio.post(baseUrl + "api/product/create-pdf", data: data);
      if (response.statusCode == 200) {
        success = true;
      }
    } catch (e) {
      _showErrorToast(AppLocalizations.of(buildContext)!.somethingWentWrong);
    }

    return success;
  }

  /// Update stock for a specific product
  Future<void> updateStock(String productNumber, String username, int amount,
      double latitude, double longitude) async {
    int? connectionCode = await testConnection();
    await _setBearerForAuthHeader();
    dynamic data = {
      "productNumber": productNumber,
      "username": username,
      "quantity": amount,
      "latitude": latitude,
      "longitude": longitude,
      "datetime": DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now())
    };
    if (connectionCode == 200) {
      await dio.post(baseUrl + "api/product/set-new-stock", data: data);
    } else {
      Map<String, dynamic> queueItem = {
        "type": "UPDATE_STOCK",
        "status": "PENDING",
        "data": data
      };
      _updateLocalStorageStock(productNumber, amount);
      OfflineEnqueueService().addToQueue(queueItem);
    }
  }

  Future<void> _updateLocalStorageStock(
      String productNumber, int amount) async {
    List<Item> storedItems =
        _getItemsFromJson(jsonDecode(await storage.read(key: "items") ?? "[]"));
    storedItems[storedItems
            .indexWhere((item) => item.productNumber == productNumber)]
        .stock += amount;
    storage.write(key: "items", value: jsonEncode(storedItems));
  }

  Future<List<Item>> _updateStoreAndGetItems(
      String? localStorage, String department) async {
    List<Item> updatedItemList = [];
    Response response = await _fetchNecessaryResponseWithItemsToUpdate(
        localStorage, department);
    if (response.statusCode == 200) {
      List<Item> apiItems = _getItemsFromResponse(response);
      if (localStorage == null ||
          localStorage.isEmpty ||
          localStorage == "[]") {
        updatedItemList = apiItems;
        storage.write(key: "items", value: jsonEncode(updatedItemList));
      } else {
        updatedItemList = await _updateAndStoreItems(apiItems, updatedItemList);
      }
      lastUpdatedDate = DateTime.now();
    }
    return updatedItemList;
  }

  Future<List<Item>> _updateAndStoreItems(
      List<Item> apiItems, List<Item> updatedItemList) async {
    String? storageString = await storage.read(key: "items");
    List<Item> itemsFromStorage = _getItemsFromJson(jsonDecode(storageString!));
    _updateItemsFromApiToList(apiItems, itemsFromStorage);
    updatedItemList = itemsFromStorage;
    await storage.write(key: "items", value: jsonEncode(updatedItemList));
    return updatedItemList;
  }

  void _updateItemsFromApiToList(List<Item> updatedItems, List<Item> items) {
    for (Item updatedItem in updatedItems) {
      final index = items.indexWhere(
          (element) => element.productNumber == updatedItem.productNumber);
      if (index >= 0) {
        items[index].stock = updatedItem.stock;
        items[index].productName = updatedItem.productName;
        items[index].barcode = updatedItem.barcode;
        items[index].desiredStock = updatedItem.desiredStock;
      } else if (index == -1) {
        items.add(updatedItem);
      }
    }
  }

  Future<Response<dynamic>> _fetchNecessaryResponseWithItemsToUpdate(
      String? localStorage, String department) async {
    Response response;
    if (lastUpdatedDate.year == 1900 ||
        localStorage == null ||
        localStorage.isEmpty) {
      response = await dio.post(baseUrl + "api/product/get-inventory",
          data: {"department": department});
    } else {
      String formattedDate =
          DateFormat('yyyy-MM-dd kk:mm:ss').format(lastUpdatedDate);
      response = await dio.post(
          baseUrl + "api/product/recently-updated-inventory",
          data: {"department": department, "DateTime": formattedDate});
    }
    return response;
  }

  List<Item> _getItemsFromResponse(Response<dynamic> response) {
    List<dynamic> products = List<dynamic>.from(response.data);
    return _getItemsFromJson(products);
  }

  List<Item> _getItemsFromJson(List<dynamic> storageItems) {
    List<Item> items = [];
    for (var product in storageItems) {
      String name = "";
      String number = "";
      String ean13 = "";
      int stock = 0;
      int desiredStock = 0;
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
            if (value.runtimeType == String) {
              stock = int.parse(value);
            } else {
              stock = value;
            }
            break;
          case "desired_Stock":
            if (value.runtimeType == String) {
              desiredStock = int.parse(value);
            } else {
              desiredStock = value;
            }

            break;
          case "desiredStock":
            if (value.runtimeType == String) {
              desiredStock = int.parse(value);
            } else {
              desiredStock = value;
            }

            break;
        }
      });
      items.add(Item(
          productName: name,
          productNumber: number,
          barcode: ean13,
          desiredStock: desiredStock,
          stock: stock));
    }
    return items;
  }

  Future<List<Item>> _getItemsFromStorage(String? localStorage) async {
    List<Item> storedItems = [];
    if (localStorage != null && localStorage.length > 3) {
      String? storageString = await storage.read(key: "items");
      storedItems = _getItemsFromJson(jsonDecode(storageString!));
    }
    return storedItems;
  }

  //#endregion

  //#region Region Order
  /// Gets pending order from api.
  /// Returns a list of orders
  Future<List<Order>> getPendingOrders() async {
    int? connectionCode = await testConnection();
    await _setBearerForAuthHeader();
    List<Order> pendingOrders = [];
    if (connectionCode == 200) {
      pendingOrders = await _getPendingOrdersFromApi();
    }
    return pendingOrders;
  }

  /// Gets users orders to confirm from api.
  /// Returns a list of orders
  Future<List<Order>> getUserConfirmedOrders() async {
    int? connectionCode = await testConnection();
    await _setBearerForAuthHeader();
    List<Order> confirmedOrders = [];
    Response response;
    if (connectionCode == 200) {
      response = await dio.post(baseUrl + "orders/user/pending",
          data: {"department": await getActiveDepartment()});
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
    await _setBearerForAuthHeader();
    List<Order> confirmedOrders = [];
    Response response;
    if (connectionCode == 200) {
      response = await dio.get(baseUrl + "orders/confirmed");
      if (response.statusCode == 200) {
        confirmedOrders = _getOrdersFromResponse(response);
      }
    }
    return confirmedOrders;
  }

  /// Update order from pending to confirmed for a specific order
  Future<void> updateOrder(String imageName, String department) async {
    await _setBearerForAuthHeader();
    if (200 == await testConnection()) {
      await dio.post(baseUrl + "orders/update",
          data: {"imageName": imageName, "department": department});
    }
  }

  ///Send order to api.
  Future<void> sendOrder(String imageName, String department) async {
    await _setBearerForAuthHeader();
    if (200 == await testConnection()) {
      await dio.post(baseUrl + "orders/new",
          data: {"imageName": imageName, "department": department});
    }
  }

  Future<List<Order>> _getPendingOrdersFromApi() async {
    List<Order> pendingOrders = [];
    Response response = await dio.get(baseUrl + "orders/admin/pending");
    if (response.statusCode == 200) {
      pendingOrders = _getOrdersFromResponse(response);
    }
    return pendingOrders;
  }

  List<Order> _getOrdersFromResponse(Response<dynamic> response) {
    List<Order> pendingOrders = [];
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
      pendingOrders.add(Order(imagename: imageName, department: department));
    }
    return pendingOrders;
  }

  //#endregion

  //#region Region Department

  /// Gets the active department from the local storage
  Future<String> getActiveDepartment() async {
    String? activeDepartment = await storage.read(key: "activeDepartment");
    if (activeDepartment == null) {
      return "";
    } else {
      return activeDepartment;
    }
  }

  /// Sets a new active department in the local storage
  Future<void> setActiveDepartment(String department) async {
    await storage.write(key: "activeDepartment", value: department);
  }

  List<String> _getDepartmentsFromResponse(Response<dynamic> response) {
    List<String> departments = [];
    List<Map<String, dynamic>> departmentsList =
        List<Map<String, dynamic>>.from(response.data);
    for (var department in departmentsList) {
      departments.add(department["name"].toString());
    }
    return departments;
  }

  //#endregion

  void _showErrorToast(String errorMessage) {
    ScaffoldMessenger.of(buildContext)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}
