import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/material.dart';


import '../../../../../../core/ui/images/image.dart';
import '../../../../../domain/entities/user.dart';
import '../../../groups/model/group.dart';

List<User> get mockUsers => [
  User(
    id: "23",
    name: 'John Doe',
    email: 'john@test.com',
    imageUrl:
    'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
    createdAt: DateTime.now(),
  ),
  User(
    id: "24",
    name: 'John Doe',
    email: 'john@test.com',
    imageUrl:
    'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
    createdAt: DateTime.now(),
  ),
];

List<Group> get groups => [
  Group(id: 'group-id', name: 'Video production I', userList: [...mockUsers]),
  Group(id: 'group-id', name: 'Video production II', userList: mockUsers),
  Group(id: 'group-id', name: 'Video production III', userList: mockUsers),
  Group(id: 'group-id', name: 'Video I', userList: mockUsers),
  Group(id: 'group-id', name: 'Video production II', userList: mockUsers),
  Group(id: 'group-id', name: 'Video production III', userList: mockUsers),
  Group(id: 'group-id', name: 'Development I', userList: mockUsers),
  Group(id: 'group-id', name: 'Development II', userList: mockUsers),
];

var maxItemsPerScreen = 3;


class NewGroupsWidget extends StatefulWidget{
  const NewGroupsWidget({super.key});


  @override
  NewGroupsWidgetState createState() => NewGroupsWidgetState();
}

class NewGroupsWidgetState extends State<NewGroupsWidget>{

  var currentPage = 1;
  var numberOfPages = (groups.length/maxItemsPerScreen).ceil();

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
                      'New Groups (${groups.length})',
                      style: context.titleTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return  Wrap(
                  runAlignment: WrapAlignment.spaceEvenly,
                  children: [
                    for (var group in groups.skip((currentPage - 1) * maxItemsPerScreen).take(maxItemsPerScreen))
                      SizedBox(
                        width: constraints.maxWidth,
                        child: Row(
                          children: [

                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.name,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.displaySmall,
                                  ),
                                  Text(
                                    '${group.userList.length} members',
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              ' Created: ${group.createdAt?.day}/${group.createdAt?.month}/${group.createdAt?.year}',
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodySmall,
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