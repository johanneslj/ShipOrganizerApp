/// Represents an Order that has to be confirmed
/// Uses image name to show a picture, department to select who sees the order
/// and status to tell if its confirmed or pending
class Order {

  final String imagename;
  final String department;
  final int status;


  Order({required this.imagename, required this.department,required this.status});


}