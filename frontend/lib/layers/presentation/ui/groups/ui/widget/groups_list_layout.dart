import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/navigation/route.dart';
import 'package:cinteraction_vc/core/ui/images/image.dart';
import 'package:cinteraction_vc/core/ui/widget/content_layout_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/ui/widget/mobile_screen_toolbar.dart';
import '../../../../cubit/groups/groups_cubit.dart';
import '../../model/group.dart';
import 'memebers_widget.dart';

class GroupListLayout extends StatelessWidget {
  final List<Group> groups;

  const GroupListLayout({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    if (context.isWide) {
      return ContentLayoutWeb(
        child: SizedBox(
          height: double.maxFinite,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Groups',
                          style: context.titleTheme.headlineLarge,
                        ),
                        Text(
                          '${groups.length} Groups',
                        )
                      ],
                    )),
                    ElevatedButton(
                        onPressed: () =>
                            {context.read<GroupsCubit>().addGroup()},
                        child: const Text('Create Group'))
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    children: [
                      for (var group in groups)
                        TableRow(children: [
                          TableCell(
                            child: InkWell(
                              onTap: () => {
                                context.read<GroupsCubit>().showDetails(group)
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.only(top: 20, bottom: 20),
                                padding: const EdgeInsets.all(20),
                                decoration: ShapeDecoration(
                                  color: ColorConstants.kWhite40,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                child: Stack(
                                  children: [

                                    Positioned(
                                        right: 0,
                                        child: imageSVGAsset('three_dots') as Widget
                                    ),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          group.name,
                                          style: context.textTheme.headlineSmall,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                                width: 200,
                                                child: Text('${group.userList.length} Memebers')),
                                            Expanded(child: MembersWidget(users: group.userList)),
                                            // Expanded(
                                            //   child: SizedBox(
                                            //     height: 48,
                                            //     child: Stack(children: [
                                            //       for (var (index, user)
                                            //           in group.userList.indexed)
                                            //         if (index == maxAvatar)
                                            //           Positioned(
                                            //               left:
                                            //                   (36 * index).toDouble(),
                                            //               child: Container(
                                            //                 width: 48,
                                            //                 height: 48,
                                            //                 padding: const EdgeInsets
                                            //                     .symmetric(
                                            //                     vertical: 8),
                                            //                 decoration:
                                            //                     ShapeDecoration(
                                            //                   color:
                                            //                       Color(0xFFF2F3F6),
                                            //                   shape:
                                            //                       RoundedRectangleBorder(
                                            //                     side: const BorderSide(
                                            //                       width: 2,
                                            //                       strokeAlign: BorderSide
                                            //                           .strokeAlignOutside,
                                            //                       color: Colors.white,
                                            //                     ),
                                            //                     borderRadius:
                                            //                         BorderRadius
                                            //                             .circular(
                                            //                                 200),
                                            //                   ),
                                            //                 ),
                                            //                 child: Center(
                                            //                     child: Text(
                                            //                         '+${group.userList.length - index}')),
                                            //               ))
                                            //         else if (index < maxAvatar)
                                            //           Positioned(
                                            //               left:
                                            //                   (36 * index).toDouble(),
                                            //               child: UserImage.medium(
                                            //                   user.imageUrl))
                                            //     ]),
                                            //   ),
                                            // )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 29,
        child: MobileToolbarScreen(
          title: 'Groups',
          body:
          SizedBox(
            height: MediaQuery.of(context).size.height - 29,

            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [

                      Expanded(child: Text('${groups.length} Groups',)),
                      IconButton(
                          onPressed: () => {context.read<GroupsCubit>().addGroup()},
                          icon: imageSVGAsset('user_plus') as Widget)
                    ],
                  ),

                  Expanded(
                    child: ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (BuildContext context, int index){
                          var group = groups[index];

                          return GestureDetector(
                            onTap: () =>{
                              context.push(AppRoute.users.path, extra: 'srdjan')
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                              child:  Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            group.name,
                                            textAlign: TextAlign.center,
                                            style: context.textTheme.headlineSmall,
                                          ),

                                          Text(
                                            '${group.userList.length} Members',
                                            textAlign: TextAlign.center,
                                            style: context.textTheme.labelSmall,
                                          ),
                                          const SizedBox(height: 20),
                                          MembersWidget(users: group.userList),
                                        ],
                                      ),
                                    ),
                          );
                        } ),
                  ),

                ],
              ),
            ),
          ),



        ),
      );
    }
  }
}
