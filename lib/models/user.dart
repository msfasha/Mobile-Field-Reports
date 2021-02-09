class User {
  String userId;
  String utilityId;
  String utilityName;
  String personName;
  String email;
  String userCategory; //normal user, utility admin, system admin.

  User(
      {this.userId,
      this.utilityId,
      this.utilityName,
      this.personName,
      this.email});
}
