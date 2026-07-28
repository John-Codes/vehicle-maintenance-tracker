class Technician {
  final String name;
  final String phone;
  final String email;
  const Technician({this.name = '', this.phone = '', this.email = ''});

  factory Technician.fromJson(Map<String, dynamic> json) => Technician(
        name: json['name'] ?? '', phone: json['phone'] ?? '', email: json['email'] ?? '');
  Map<String, dynamic> toJson() => {'name': name, 'phone': phone, 'email': email};
}
