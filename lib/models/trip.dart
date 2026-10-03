class Prefs {
  String arrive; // yyyy-MM-dd
  int arriveT; // minutes from midnight
  String depart;
  int departT;
  int adults;
  int kids;
  int? youngest;
  List<String> interests;
  String budget; // economical | moderate | premium | luxury
  double? customBudget;
  String pace; // relaxed | balanced | busy
  List<String> diet;
  List<String> access;
  String transport; // taxi | car | walk | bus
  String hotel;
  bool indoor;

  Prefs({
    required this.arrive,
    this.arriveT = 900,
    required this.depart,
    this.departT = 1080,
    this.adults = 2,
    this.kids = 0,
    this.youngest,
    List<String>? interests,
    this.budget = 'moderate',
    this.customBudget,
    this.pace = 'balanced',
    List<String>? diet,
    List<String>? access,
    this.transport = 'taxi',
    this.hotel = 'city',
    this.indoor = false,
  })  : interests = interests ?? [],
        diet = diet ?? [],
        access = access ?? [];

  int get party => adults + kids;

  Prefs copy() => Prefs.fromJson(toJson());

  Map<String, dynamic> toJson() => {
        'arrive': arrive, 'arriveT': arriveT, 'depart': depart, 'departT': departT,
        'adults': adults, 'kids': kids, 'youngest': youngest, 'interests': interests,
        'budget': budget, 'customBudget': customBudget, 'pace': pace, 'diet': diet,
        'access': access, 'transport': transport, 'hotel': hotel, 'indoor': indoor,
      };

  factory Prefs.fromJson(Map<String, dynamic> j) => Prefs(
        arrive: j['arrive'], arriveT: j['arriveT'], depart: j['depart'], departT: j['departT'],
        adults: j['adults'], kids: j['kids'], youngest: j['youngest'],
        interests: List<String>.from(j['interests'] ?? []), budget: j['budget'],
        customBudget: (j['customBudget'] as num?)?.toDouble(), pace: j['pace'],
        diet: List<String>.from(j['diet'] ?? []), access: List<String>.from(j['access'] ?? []),
        transport: j['transport'], hotel: j['hotel'], indoor: j['indoor'] ?? false,
      );
}

enum ItemKind { arrive, depart, place, event, meal, hotelBreak }

/// Why something was recommended: k = match | dated | near | family | cool
class Why {
  final String k;
  final List<String> v;
  final double? d;
  const Why(this.k, {this.v = const [], this.d});
  Map<String, dynamic> toJson() => {'k': k, 'v': v, 'd': d};
  factory Why.fromJson(Map<String, dynamic> j) =>
      Why(j['k'], v: List<String>.from(j['v'] ?? []), d: (j['d'] as num?)?.toDouble());
}

/// Booking status. The app never sets `confirmed` on its own:
/// only a provider confirmation (or a number the visitor enters) does.
enum BookingStatus { recommended, available, reserved, paymentRequired, confirmed, cancelled, info }

class TripItem {
  String uid;
  ItemKind kind;
  String? ref;
  String? meal; // b | l | d
  int start;
  int end;
  double lat;
  double lng;
  bool kept;
  BookingStatus status;
  String? occ;
  int? seats;
  double? price;
  List<Why> why;
  int? travel;
  double? dist;
  String? conf;

  TripItem({
    required this.uid,
    required this.kind,
    this.ref,
    this.meal,
    required this.start,
    required this.end,
    required this.lat,
    required this.lng,
    this.kept = false,
    this.status = BookingStatus.recommended,
    this.occ,
    this.seats,
    this.price,
    List<Why>? why,
    this.travel,
    this.dist,
    this.conf,
  }) : why = why ?? [];

  bool get locked => kept || status == BookingStatus.confirmed || kind == ItemKind.arrive || kind == ItemKind.depart;
  bool get isActivity => kind == ItemKind.place || kind == ItemKind.event;

  TripItem clone() => TripItem.fromJson(toJson());

  Map<String, dynamic> toJson() => {
        'uid': uid, 'kind': kind.name, 'ref': ref, 'meal': meal, 'start': start, 'end': end,
        'lat': lat, 'lng': lng, 'kept': kept, 'status': status.name, 'occ': occ, 'seats': seats,
        'price': price, 'why': why.map((w) => w.toJson()).toList(), 'travel': travel, 'dist': dist,
        'conf': conf,
      };

  factory TripItem.fromJson(Map<String, dynamic> j) => TripItem(
        uid: j['uid'], kind: ItemKind.values.byName(j['kind']), ref: j['ref'], meal: j['meal'],
        start: j['start'], end: j['end'], lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(), kept: j['kept'] ?? false,
        status: BookingStatus.values.byName(j['status']), occ: j['occ'], seats: j['seats'],
        price: (j['price'] as num?)?.toDouble(),
        why: ((j['why'] ?? []) as List).map((w) => Why.fromJson(Map<String, dynamic>.from(w))).toList(),
        travel: j['travel'], dist: (j['dist'] as num?)?.toDouble(), conf: j['conf'],
      );
}

class TripDay {
  String date;
  String? pace;
  List<TripItem> items;
  TripDay(this.date, {this.pace, List<TripItem>? items}) : items = items ?? [];
  Map<String, dynamic> toJson() => {'date': date, 'pace': pace, 'items': items.map((i) => i.toJson()).toList()};
  factory TripDay.fromJson(Map<String, dynamic> j) => TripDay(j['date'],
      pace: j['pace'],
      items: ((j['items'] ?? []) as List).map((i) => TripItem.fromJson(Map<String, dynamic>.from(i))).toList());
}

class Trip {
  Prefs prefs;
  List<TripDay> days;
  Trip(this.prefs, this.days);
  Map<String, dynamic> toJson() => {'prefs': prefs.toJson(), 'days': days.map((d) => d.toJson()).toList()};
  factory Trip.fromJson(Map<String, dynamic> j) => Trip(Prefs.fromJson(Map<String, dynamic>.from(j['prefs'])),
      ((j['days'] ?? []) as List).map((d) => TripDay.fromJson(Map<String, dynamic>.from(d))).toList());
}
