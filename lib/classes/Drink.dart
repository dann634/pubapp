class Drink {
  String username;
  String fullname;
  String units;
  String type;
  String time;

  Drink(this.username, this.fullname, this.units, this.type, this.time);

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "fullname": fullname,
      "units": units,
      "type": type,
      "time": time,
    };
  }

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      json["username"], json["fullname"], json["units"], json["type"], json["time"],
    );
  }
}