import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/extension/image.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/app/app_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/ui/images/image.dart';
import '../../../../../../core/util/menu_items.dart';

import '../../../../cubit/chat/chat_cubit.dart';
import '../../../profile/ui/widget/user_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.getCurrentUser;
    final tabs = context.isWide
        ? desktopMenu
            .where((item) => item != aiModules || user?.companyAdmin == true)
            .toList()
        : mobileBottomMenu
            .where((item) => item != aiModules || user?.companyAdmin == true)
            .toList();

    final content = tabs[_selectedIndex].builder(context);

    context.textTheme.labelSmall;

    void handleClick(BuildContext context, String value) {
      switch (value) {
        case 'LogOut':
          context.logOut();
          break;
      }
    }

    // final chatCubit = context.watch<ChatCubit>();

    // return BlocConsumer<ChatCubit, ChatState>(
    //   builder: (context, state) {
    final Widget body;
    final Widget? bottomNavigationBar;

    if (context.isWide) {
      body = Row(
        children: [
          Visibility(
            // visible: _selectedIndex != 3,
            visible: true,

            child: SizedBox(
              width: 70,
              child: Column(
                children: [
                  for (final (index, item) in tabs.indexed)
                    Container(
                      color: _selectedIndex == index
                          ? ColorConstants.kPrimaryColor.withOpacity(0.05)
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                InkWell(
                                  onTap: () => {
                                    setState(() {
                                      _selectedIndex = index;
                                    })
                                  },
                                  child: Container(
                                      width: double.maxFinite,
                                      child: Column(
                                        children: [
                                          (_selectedIndex == index
                                              ? imageSVGAsset(item.assetName)
                                                  ?.copyWith(
                                                      colorFilter:
                                                          const ColorFilter
                                                              .mode(
                                                              ColorConstants
                                                                  .kPrimaryColor,
                                                              BlendMode.srcIn))
                                              : imageSVGAsset(
                                                  item.assetName)) as Widget,
                                          // ),

                                          Text(
                                            item.label,
                                            style: context.textTheme.labelSmall
                                                ?.copyWith(
                                                    color: _selectedIndex ==
                                                            index
                                                        ? ColorConstants
                                                            .kPrimaryColor
                                                        : Colors.black45),
                                          ),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: content),
        ],
      );
      bottomNavigationBar = null;
    } else {
      body = SafeArea(child: content);
      bottomNavigationBar = BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          for (final tab in tabs)
            BottomNavigationBarItem(
              label: tab.label,
              icon: imageSVGAsset(tab.assetName) as Widget,
              activeIcon: imageSVGAsset(tab.assetName)?.copyWith(
                  colorFilter: const ColorFilter.mode(
                      ColorConstants.kPrimaryColor, BlendMode.srcIn)) as Widget,
            ),
        ],
      );
    }

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final currentUser = state.user;
        return Scaffold(
          appBar: context.isWide
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(97),
                  child: Container(
                    height: 97,
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                              onTap: () => {
                                    setState(() {
                                      _selectedIndex = 0;
                                    }),
                                  },
                              child: imageSVGAsset('original_long_logo')
                                  as Widget),
                        ),
                        const Spacer(),
                        if (currentUser != null)
                          Row(
                            children: [
                              const Visibility(
                                  visible: false, child: Text("NEXT MEETING")),
                              const SizedBox(width: 15),
                              UserImage.medium([currentUser.getUserImageDTO()]),
                              const SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentUser.name,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleSmall,
                                  ),
                                  // Text(
                                  //   'Participant',
                                  //   textAlign: TextAlign.center,
                                  //   style: context.textTheme.labelSmall,
                                  // ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              Tooltip(
                                message: 'LogOut',
                                child: IconButton(
                                  icon: const Icon(Icons.logout),
                                  onPressed: () =>
                                      handleClick(context, 'LogOut'),
                                ),
                              )
                            ],
                          ),
                      ],
                    ),
                  ),
                )
              : null,
          body: BlocProvider.value(
            value: context.read<ChatCubit>(), // Keep using the same ChatCubit
            child: body,
          ),
          bottomNavigationBar: bottomNavigationBar,
        );
      },
    );
    //   },
    //   listener: (BuildContext context, ChatState state) {
    //     print(state);
    //   },
    // );
  }
}
