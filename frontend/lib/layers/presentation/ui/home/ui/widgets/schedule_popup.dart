import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../core/ui/input/input_field.dart';
import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/home/home_cubit.dart';

class SchedulePopup extends StatefulWidget {
  const SchedulePopup({super.key, required this.context, required this.state});
  final BuildContext context;
  final ChatState state;

  @override
  State<SchedulePopup> createState() => _SchedulePopupState();
}

class _SchedulePopupState extends State<SchedulePopup> {
  @override
  Widget build(BuildContext innerContext) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final tagController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    late TextEditingController autocompleteController;

    final List<UserDto> selectedParticipants = [];
    final List<UserDto>? allUsers = widget.state.users;

    return BlocProvider.value(
      value: widget.context.read<HomeCubit>(),
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (c, s) {},
        builder: (innerContext, state) => AlertDialog(
          title: const Text(
            'Schedule a Meet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColorConstants.kPrimaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputField.name(
                      label: 'Full Name',
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: "Event Description",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    // TextField(
                    //   controller: tagController,
                    //   decoration: const InputDecoration(
                    //     labelText: "Tag Name",
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Choose Participants',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
                          children: selectedParticipants.map((user) {
                            return Chip(
                              label: Text(user.name,
                                  style: const TextStyle(
                                    color: ColorConstants.kBlack1,
                                  )),
                              onDeleted: () {
                                selectedParticipants.remove(user);
                                (innerContext as Element).markNeedsBuild();
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 15),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Autocomplete<UserDto>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable.empty();
                                }
                                return allUsers!.where((user) =>
                                    user.name.toLowerCase().contains(
                                        textEditingValue.text.toLowerCase()) &&
                                    !selectedParticipants.contains(user));
                              },
                              displayStringForOption: (UserDto option) =>
                                  option.name,
                              onSelected: (UserDto selection) {
                                if (selection.name == "Select All") {
                                  final remainingUsers = allUsers!
                                      .where((user) =>
                                          !selectedParticipants.contains(user))
                                      .toList();
                                  selectedParticipants.addAll(remainingUsers);
                                } else {
                                  if (!selectedParticipants
                                      .contains(selection)) {
                                    selectedParticipants.add(selection);
                                  }
                                }

                                autocompleteController.clear();
                                (innerContext as Element).markNeedsBuild();
                              },
                              fieldViewBuilder: (context, controller, focusNode,
                                  onEditingComplete) {
                                autocompleteController = controller;
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  onEditingComplete: onEditingComplete,
                                  decoration: const InputDecoration(
                                    labelText: "Choose Participants",
                                    hintText: "Start typing name...",
                                    border: OutlineInputBorder(),
                                  ),
                                );
                              },
                              optionsViewBuilder:
                                  (context, onSelected, options) {
                                final selectAllOption = UserDto(
                                    id: 'select_all',
                                    name: 'Select All',
                                    email: '',
                                    imageUrl: '');
                                final extendedOptions = [
                                  selectAllOption,
                                  ...options
                                ];

                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 4,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(4.0)),
                                    ),
                                    child: Container(
                                      width: constraints.maxWidth,
                                      height: 52.0 *
                                          extendedOptions.length
                                              .clamp(1, 6), // max 6 items
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: extendedOptions.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final UserDto option =
                                              extendedOptions[index];
                                          return InkWell(
                                            onTap: () => onSelected(option),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Text(option.name),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        const Text('Date:'),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: widget.context,
                              firstDate:
                                  DateTime.now().add(const Duration(hours: 1)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 90)),
                              initialDate:
                                  state.scheduleStartDateTime ?? DateTime.now(),
                            );
                            if (selectedDate != null) {
                              innerContext
                                  .read<HomeCubit>()
                                  .setScheduleDate(selectedDate);
                            }
                          },
                          icon: const Icon(Icons.edit_calendar_outlined,
                              size: 16),
                          label: Text(
                            DateFormat('dd/MM/yyyy').format(
                              state.scheduleStartDateTime ?? DateTime.now(),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18),
                        const SizedBox(width: 8),
                        const Text('Time:'),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: () async {
                            final selectedTime = await showTimePicker(
                              context: widget.context,
                              initialTime: TimeOfDay.fromDateTime(
                                state.scheduleStartDateTime ?? DateTime.now(),
                              ),
                            );
                            if (selectedTime != null) {
                              innerContext
                                  .read<HomeCubit>()
                                  .setScheduleTime(selectedTime);
                            }
                          },
                          icon: const Icon(Icons.schedule, size: 16),
                          label: Text(
                            DateFormat('HH:mm').format(
                              state.scheduleStartDateTime ?? DateTime.now(),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(widget.context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                List<String> emailList =
                    selectedParticipants.map((user) => user.email).toList();
                print('Emails to send: $emailList');

                await context.read<HomeCubit>().scheduleMeeting(
                    nameController.text,
                    descController.text,
                    tagController.text,
                    emailList);

                // try {
                //   final link = response.response?.scheduledAt ?? '';
                //   if (DateTime.now() > response.response?.scheduledAt) {
                //     context.read<HomeCubit>().getNextMeeting();
                //   }
                // } catch (e) {
                //   print(e.toString());
                // }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.kPrimaryColor,
              ),
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
