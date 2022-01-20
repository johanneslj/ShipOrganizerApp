import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DepartmentCard extends StatelessWidget {
  final String departmentName;

  const DepartmentCard({Key? key, required this.departmentName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        InkWell(
          child: Row(
            children: [
              Text(
                departmentName,
              ),
            ],
          ),
        ),
        const Divider(
          color: Color(0xffD3D6D7),
        ),
      ],
    );

    throw UnimplementedError();
  }
}
