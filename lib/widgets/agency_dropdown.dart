import 'package:flutter/material.dart';
import 'package:ufr/shared/globals.dart';

class AgencyDropDown extends StatelessWidget {
  const AgencyDropDown({
    Key key,
    @required String agencyId,
    @required Function onChanged,
  })  : _agencyId = agencyId,
        _onChanged = onChanged,
        super(key: key);

  final String _agencyId;
  final ValueSetter<String> _onChanged;

  @override
  Widget build(BuildContext context) {
    if (Globals.agenciesSnapshot == null)
      return const Center(
        child: const Text('...'),
      );
    else {
      return Container(
        alignment: Alignment.centerLeft,
        child: DropdownButtonFormField(
            decoration: InputDecoration(
                labelText: 'Agency/Utility',
                hintText: 'Select agency',
                hintStyle: TextStyle(fontSize: 12.0, color: Colors.grey)),
            value: _agencyId,
            validator: (val) => (val == null) ? 'Select Agency/Utility' : null,
            onChanged: (val) => _onChanged(val),
            items: Globals.agenciesSnapshot.docs
                .map((document) => DropdownMenuItem(
                    value: document.id, child: Text(document['name'] ?? '')))
                .toList()),
      );
    }
  }
}
