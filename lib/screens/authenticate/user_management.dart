import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/shared/firebase_services.dart';
import 'package:ufr/shared/loading.dart';
import 'package:ufr/shared/modules.dart';
import 'package:ufr/widgets/agency_dropdown.dart';

class UserManagement extends StatefulWidget {
  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  String _agencyId;
  List<UserProfile> _dataModel = List<UserProfile>();
  List<bool> _itemSavingEffect;
  bool _loadingEffect = true;

  getUsersList(String agencyId) async {
    setState(() {
      _loadingEffect = true;
    });

    OperationResult or;

    //this operation always returns a value, even if agencyId is null
    or = await DataService.getUsersProfilesByAgencyId(agencyId);

    setState(() {
      _dataModel = or.content;
      _itemSavingEffect =
          List<bool>.filled((or.content as List<UserProfile>).length, false);
      _loadingEffect = false;
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await getUsersList(null);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);

    return SafeArea(
      child: new Scaffold(
          key: userManagementScafoldKey,
          appBar: AppBar(title: Text('Users Management')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                child: AgencyDropDown(
                  agencyId: _agencyId, //make sure this is not static
                  onChanged: (value) {
                    getUsersList(value);
                  },
                ),
              ),
              Expanded(
                  child: _loadingEffect
                      ? Loading()
                      : ListView.builder(
                          itemCount: _dataModel.length,
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                _dataModel[index].email,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5),
                              ),
                              subtitle: new Text(
                                _dataModel[index].personName +
                                    ' ' +
                                    _dataModel[index].phoneNumber,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5),
                              ),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        _dataModel[index].userStatus == true
                                            ? 'Active'
                                            : 'Not Active',
                                        style: TextStyle(
                                            color:
                                                _dataModel[index].userStatus ==
                                                        true
                                                    ? Colors.green
                                                    : Colors.red)),
                                    //put space between text and checkbox/ActivityIndicator
                                    SizedBox(width: 10),
                                    //constrain both checkbox/or/activity indicator with a fixed bound
                                    //so that the word/text active stops flipping when the status is changed
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: _itemSavingEffect[index] == true
                                          ? SpinKitThreeBounce(
                                              color:
                                                  Theme.of(context).accentColor,
                                              size: 20.0,
                                            )
                                          : Checkbox(
                                              value:
                                                  _dataModel[index].userStatus,
                                              onChanged: (bool val) async {
                                                setState(() {
                                                  _dataModel[index].userStatus =
                                                      val;
                                                  _itemSavingEffect[index] =
                                                      true;
                                                });
                                                OperationResult result =
                                                    await DataService
                                                        .updateUserStatus(
                                                            _dataModel[index]
                                                                .userId,
                                                            val,
                                                            user.userId);

                                                setState(() {
                                                  _itemSavingEffect[index] =
                                                      false;
                                                });

                                                //if an error occured, return keep the checkbox state as before
                                                if (result.operationCode ==
                                                    OperationResultCodeEnum
                                                        .Error) {
                                                  setState(() {
                                                    _dataModel[index]
                                                            .userStatus =
                                                        !_dataModel[index]
                                                            .userStatus;
                                                  });
                                                  showSnackBarMessage(
                                                      _dataModel[index].email +
                                                          ' Error occured, status was NOT updated',
                                                      userManagementScafoldKey);
                                                } else {
                                                  showSnackBarMessage(
                                                      _dataModel[index].email +
                                                          ' status was updated',
                                                      userManagementScafoldKey);
                                                }
                                              }),
                                    ),
                                  ]),
                            );
                          },
                        )),
            ],
          )),
    );
  }
}
