import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:flutter/material.dart';

class AddParticipantsDialog extends StatefulWidget {
  final List<UserDto> users;
  final Function(List<dynamic>) onAddParticipants;
  final BuildContext context;

  const AddParticipantsDialog({
    super.key,
    required this.users,
    required this.onAddParticipants,
    required this.context,
  });

  @override
  State<AddParticipantsDialog> createState() => _AddParticipantsDialogState();
}

class _AddParticipantsDialogState extends State<AddParticipantsDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredUsers = [];
  List<dynamic> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.users;
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = widget.users
          .where(
              (user) => user.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext innerContext) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Add to Group",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _filterUsers,
            decoration: InputDecoration(
              hintText: "Search users",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Container(
            height: 400,
            width: 400,
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                final isSelected = _selectedUsers.contains(user);

                return CheckboxListTile(
                  value: isSelected,
                  title: Text(user.name),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedUsers.add(user);
                      } else {
                        _selectedUsers.remove(user);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onAddParticipants(_selectedUsers);
            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
