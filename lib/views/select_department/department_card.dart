import 'package:flutter/material.dart';

class DepartmentCard extends StatelessWidget {
  final String departmentName;
  final String destination;

  const DepartmentCard(
      {Key? key, required this.departmentName, required this.destination})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
            onTap: () => {Navigator.pushNamed(context, destination)}),
        const Divider(
          color: Color(0xffD3D6D7),
        ),
      ],
    );
  }
}
