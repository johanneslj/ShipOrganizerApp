class RequestDataModel {
  final Map<String, dynamic> data;

  RequestDataModel({
    required this.data
  });

  factory RequestDataModel.fromString() => RequestDataModel(
      data: {}
  );


  @override
  String toString() {
    return 'RequestDataModel{data: $data}';
  }

}