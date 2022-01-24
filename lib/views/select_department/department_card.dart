import 'package:flutter/material.dart';
import 'package:ship_organizer_app/main.dart';

class DepartmentCard extends StatelessWidget {
  final String departmentName;

  const DepartmentCard({Key? key, required this.departmentName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            onTap: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => (const MyApp()) //ForgotPasswordPage())),
                          ))
                }),
        const Divider(
          color: Color(0xffD3D6D7),
        ),
      ],
    );

  }
}
