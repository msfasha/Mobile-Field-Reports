import 'package:flutter/material.dart';
import 'package:ufr/shared/globals.dart';

class AgencyDropDown extends StatelessWidget {
  final ValueSetter<String> _onChanged;

  const AgencyDropDown(this._onChanged, {super.key});

  @override
  Widget build(BuildContext context) {
    String? agencyId;

    if (Globals.agenciesSnapshot == null) {
      return const Center(
        child: Text('...'),
      );
    } else {
      return Container(
        alignment: Alignment.centerLeft,
        child: DropdownButtonFormField(
            decoration: const InputDecoration(
                labelText: 'Agency/Utility',
                hintText: 'Select agency',
                hintStyle: TextStyle(fontSize: 12.0, color: Colors.grey)),
            value: agencyId,
            validator: (val) => (val == null) ? 'Select Agency/Utility' : null,
            onChanged: (val) => _onChanged(val!),
            items: Globals.agenciesSnapshot?.docs
                .map((document) => DropdownMenuItem(
                    value: document.id, child: Text(document['name'] ?? '')))
                .toList()),
      );
    }
  }
}
