import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:cinteraction_vc/core/ui/images/image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/entities/user.dart';
import '../../../insights/ui/widget/graph_filter.dart';
import '../../../profile/ui/widget/user_image.dart';



List<User> get users => [
  User(
    id: "23",
    name: 'John Doe 1',
    email: 'john@test.com',
    imageUrl:
    'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
    createdAt: DateTime.now(),
  ),
  User(
    id: "24",
    name: 'John Doe 2',
    email: 'john@test.com',
    imageUrl:
    'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
    createdAt: DateTime.now(),
  ),
  User(
    id: "25",
    name: 'John Doe 3',
    email: 'john@test.com',
    imageUrl:
    'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
    createdAt: DateTime.now(),
  ),
  User(
    id: "26",
    name: 'John Doe 4',
    email: 'john@test.com',
    imageUrl:
    'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
    createdAt: DateTime.now(),
  ),
  User(
    id: "27",
    name: 'John Doe 5',
    email: 'john@test.com',
    imageUrl:
    'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
    createdAt: DateTime.now(),
  ),
  User(
    id: "38",
    name: 'John Doe 6',
    email: 'john@test.com',
    imageUrl:
    'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
    createdAt: DateTime.now(),
  ),
  User(
    id: "39",
    name: 'John Doe 7',
    email: 'john@test.com',
    imageUrl:
    'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
    createdAt: DateTime.now(),
  ),
  User(
    id: "30",
    name: 'John Doe 8',
    email: 'john@test.com',
    imageUrl:
    'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
    createdAt: DateTime.now(),
  ),
];

var maxItemsPerScreen = 6;

class NewUsersWidget extends StatefulWidget{
  const NewUsersWidget({super.key});


  @override
  NewUsersWidgetState createState() => NewUsersWidgetState();

}

class NewUsersWidgetState extends State<NewUsersWidget> {

  var currentPage = 1;
  var numberOfPages = (users.length/maxItemsPerScreen).ceil();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'New Users (${users.length})',
                      style: context.titleTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Visibility(visible: context.isWide, child: GraphFilter()),
                ],
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return  Wrap(
                    runAlignment: WrapAlignment.spaceBetween,
                    children: [
                      for (var user in users.skip((currentPage - 1) * maxItemsPerScreen).take(maxItemsPerScreen))
                        SizedBox(
                          width: constraints.maxWidth / 2,
                          child: Row(
                            children: [
                              UserImage.medium([user.getUserImageDTO()]),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.displaySmall,
                                  ),
                                  Text(
                                    user.email,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                    ],

                );
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: Visibility(
                  visible: currentPage!=1,
                  child: OutlinedButton(
                      onPressed: () => {
                        setState(() {
                          currentPage--;
                        })
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            width: 1,
                            color: Color(0xFFBDBDBD)),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 1,
                              color: Color(0xFFBDBDBD)),
                          borderRadius:
                          BorderRadius.circular(8),
                        ),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        )
                      ),
                      child: Transform.flip(
                        flipX: true,
                        child:  imageSVGAsset('arrow_right'),
                      )),
                ),
              ),

              const SizedBox(width: 18,),

              Text(
                'Page $currentPage of $numberOfPages',
                style: context.textTheme.labelMedium,
              ),
              const SizedBox(width: 18,),


              SizedBox(
                width: 36,
                height: 36,
                child:

                Visibility(
                  visible: currentPage < numberOfPages,
                  child: OutlinedButton(
                      onPressed: () => {
                      setState(() {
                        currentPage++;
                      })
                      },
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              width: 1,
                              color: Color(0xFFBDBDBD)),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1,
                                color: Color(0xFFBDBDBD)),
                            borderRadius:
                            BorderRadius.circular(8),
                          ),

                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          )
                      ),
                      child: Container(
                          child: imageSVGAsset('arrow_right'))),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
