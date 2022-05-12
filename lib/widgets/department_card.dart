import 'package:flutter/material.dart';
import 'package:ship_organizer_app/api_handling/api_controller.dart';

/// Represents a card containing a department, is pressable
class DepartmentCard extends StatelessWidget {
  final String departmentName;
  final String destination;
  final String arguments;

  const DepartmentCard({Key? key, required this.departmentName, required this.destination, required this.arguments})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ApiService apiService = ApiService.getInstance();
    return Column(
      children: [
        InkWell(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    departmentName,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_sharp,
                  )
                ],
              ),
            ),
            onTap: () async => {
              if(arguments.contains("department")){
                await apiService.storage.write(key: "activeDepartment", value: departmentName)
              },
              Navigator.pushNamed(context, destination, arguments: arguments)
            }
        ),
        const Divider(
          color: Color(0xffD3D6D7),
        ),
      ],
    );
  }
}
