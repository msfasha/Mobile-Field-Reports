import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ufr/shared/firebase_services.dart';

class UserManagement extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    String _agencyId;
    
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Users Management'),
      ),
      // ignore: missing_return
      body: ListView(
        children: [
          FutureBuilder<QuerySnapshot>(
                        future: DataService.agencies,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return const Center(
                              child: const Text('...'),
                            );
                          else {
                            return Container(
                              alignment: Alignment.centerLeft,
                              child: DropdownButtonFormField(
                                  decoration: InputDecoration(
                                      labelText: 'agency',
                                      hintText: 'Select agency',
                                      hintStyle: TextStyle(
                                          fontSize: 12.0, color: Colors.grey)),
                                  value: _agencyId,
                                  validator: (val) => (val == null)
                                      ? 'Select Agency/Utility'
                                      : null,
                                  //isDense: true,
                                  onChanged: (value) {
                                    
                                  },
                                  items: snapshot.data.docs
                                      .map((document) => DropdownMenuItem(
                                          // value: document.data['agency_id'],
                                          // child: Text(document.data['plant_name']),
                                          value: document.id,
                                          //value: document['agency_id'],
                                          child: Text(document['name'] ?? '')))
                                      .toList()),
                            );
                          }
                        }),
          Text('Select Agency'),
          Text('Users List'),
        ],
      ),
    );
  }
}
