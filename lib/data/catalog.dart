// Seed catalog for the prototype.
// Venue names and approximate locations are real. Opening hours, prices,
// events, showtimes and seat counts are DEMO values (demo: true) until real
// data comes from the admin dashboard or a signed partner.
// Later this file is replaced by an API call to the backend.

enum ListingType { place, restaurant, event }

class Listing {
  final String id;
  final ListingType type;
  final String en;
  final String ar;
  final String cat;
  final List<String> tags;
  final String area;
  final double lat;
  final double lng;
  final int dur; // minutes
  final double price; // KWD per adult
  final double? child; // KWD per child (null = same as adult)
  final int minAge;
  final bool indoor;
  final bool acc; // step-free access
  final double pop; // 0..1 popularity
  final List<List<int>> hours; // default opening windows, minutes from midnight
  final Map<int, List<List<int>>> except; // weekday (0=Sun..6=Sat) -> windows, [] = closed
  final List<int>? months; // seasonal availability
  final List<String> meals; // restaurants: b, l, d, s (cafe stop)
  final bool veg;
  final String motif;
  final String desc;
  final String descAr;
  final bool demo;
  // events
  final String? venue;
  final List<int>? days; // null = every day
  final List<int> times; // start times
  final String lang;
  // booking
  final String? provider;
  final String? bookUrl;
  // imagery
  final String? imageUrl;
  final String? logoUrl;
  final List<String> photos; // swipeable gallery (dishes / interior shots)
  final String? menuUrl;

  const Listing({
    required this.id,
    required this.type,
    required this.en,
    required this.ar,
    required this.cat,
    required this.tags,
    required this.area,
    required this.lat,
    required this.lng,
    required this.dur,
    required this.price,
    this.child,
    this.minAge = 0,
    this.indoor = true,
    this.acc = true,
    this.pop = .5,
    this.hours = const [],
    this.except = const {},
    this.months,
    this.meals = const [],
    this.veg = true,
    required this.motif,
    required this.desc,
    required this.descAr,
    this.demo = false,
    this.venue,
    this.days,
    this.times = const [],
    this.lang = '',
    this.provider,
    this.bookUrl,
    this.imageUrl,
    this.logoUrl,
    this.photos = const [],
    this.menuUrl,
  });

  bool get isEvent => type == ListingType.event;
  bool get isRestaurant => type == ListingType.restaurant;
  String name(String lang) => lang == 'ar' ? ar : en;
  String description(String lang) => lang == 'ar' ? descAr : desc;
}

class Venue {
  final String en, ar, area;
  final double lat, lng;
  final String? provider, url;
  const Venue(this.en, this.ar, this.lat, this.lng, this.area, {this.provider, this.url});
  String name(String lang) => lang == 'ar' ? ar : en;
}

class Hotel {
  final String en, ar;
  final double lat, lng;
  const Hotel(this.en, this.ar, this.lat, this.lng);
}

class Interest {
  final String id, en, ar, motif;
  final bool main;
  const Interest(this.id, this.en, this.ar, this.motif, {this.main = false});
}

List<List<int>> h(int open, int close) => [
      [open, close]
    ];

const kwi = (lat: 29.2266, lng: 47.9689);

const hotels = <String, Hotel>{
  'city': Hotel('Kuwait City', 'مدينة الكويت', 29.3759, 47.9774),
  'sharq': Hotel('Sharq / Gulf Road', 'شرق / شارع الخليج', 29.3855, 47.9985),
  'salmiya': Hotel('Salmiya', 'السالمية', 29.3390, 48.0760),
  'shuwaikh': Hotel('Shuwaikh', 'الشويخ', 29.3470, 47.9450),
  'fahaheel': Hotel('Fahaheel / Mangaf', 'الفحيحيل / المنقف', 29.0900, 48.1300),
  'airport': Hotel('Near the airport', 'قرب المطار', 29.2400, 47.9800),
};

const providers = <String, ({String name, String url})>{
  'eventat': (name: 'Eventat', url: 'https://www.eventat.com'),
  'arena': (name: 'The Arena Kuwait', url: 'https://www.thearenakuwait.com'),
  'cinescape': (name: 'Cinescape', url: 'https://www.cinescape.com.kw'),
  'jacc_tickets': (name: 'JACC Tickets', url: 'https://tickets.jacc-kw.com'),
  'opentable': (name: 'OpenTable', url: 'https://www.opentable.com/kuwait'),
};

const interests = <Interest>[
  Interest('concerts', 'Concerts', 'حفلات', 'stage', main: true),
  Interest('theatre', 'Theatre & plays', 'مسرح', 'stage', main: true),
  Interest('cinema', 'Movies', 'سينما', 'film', main: true),
  Interest('sports', 'Sports', 'رياضة', 'ball', main: true),
  Interest('culture', 'Kuwaiti culture', 'الثقافة الكويتية', 'sadu', main: true),
  Interest('museums', 'Museums', 'متاحف', 'frame', main: true),
  Interest('kuwaiti_food', 'Kuwaiti food', 'المطبخ الكويتي', 'plate', main: true),
  Interest('cafes', 'Cafés', 'مقاهي', 'cup', main: true),
  Interest('shopping', 'Shopping', 'تسوق', 'bag', main: true),
  Interest('beaches', 'Beaches', 'شواطئ', 'waves', main: true),
  Interest('desert', 'Desert & camping', 'البر والتخييم', 'dunes', main: true),
  Interest('family', 'Family', 'العائلة', 'leaf', main: true),
  Interest('live_music', 'Live music', 'موسيقى حية', 'stage'),
  Interest('comedy', 'Comedy', 'كوميديا', 'stage'),
  Interest('football', 'Football', 'كرة القدم', 'ball'),
  Interest('motorsports', 'Motorsports', 'رياضة السيارات', 'speed'),
  Interest('heritage', 'Heritage', 'تراث', 'arch'),
  Interest('architecture', 'Architecture', 'عمارة', 'towers'),
  Interest('fine_dining', 'Fine dining', 'مطاعم راقية', 'plate'),
  Interest('desserts', 'Desserts', 'حلويات', 'cup'),
  Interest('luxury', 'Luxury shopping', 'تسوق فاخر', 'bag'),
  Interest('markets', 'Local markets', 'أسواق شعبية', 'arch'),
  Interest('watersports', 'Watersports', 'رياضات مائية', 'waves'),
  Interest('adventure', 'Adventure', 'مغامرة', 'dunes'),
  Interest('kids', "Children's fun", 'ترفيه الأطفال', 'star'),
  Interest('wellness', 'Wellness & spas', 'عافية وسبا', 'leaf'),
  Interest('photography', 'Photography', 'تصوير', 'towers'),
  Interest('art', 'Art & exhibitions', 'فنون ومعارض', 'frame'),
  Interest('festivals', 'Festivals', 'مهرجانات', 'star'),
];

const venues = <String, Venue>{
  'arena': Venue('The Arena Kuwait', 'ذا أرينا الكويت', 29.2697, 47.9907, 'Zahra', provider: 'arena'),
  'jacc': Venue('Sheikh Jaber Al-Ahmad Cultural Centre', 'مركز الشيخ جابر الأحمد الثقافي', 29.3652, 47.9930, 'Sharq', provider: 'jacc_tickets'),
  'stadium': Venue('Jaber Al-Ahmad International Stadium', 'استاد جابر الأحمد الدولي', 29.2625, 47.9064, 'Ardiya', provider: 'eventat'),
  'cinema': Venue('Cinescape 360', 'سينسكيب ٣٦٠', 29.2700, 47.9910, 'Zahra', provider: 'cinescape'),
  'theatre': Venue('Salmiya theatre (demo venue)', 'مسرح السالمية (تجريبي)', 29.3360, 48.0740, 'Salmiya', provider: 'eventat'),
  'sadu': Venue('Sadu House', 'بيت السدو', 29.3833, 47.9861, 'Gulf Road', provider: 'eventat'),
  'marina': Venue('Souk Sharq marina', 'مرسى سوق شرق', 29.3840, 48.0005, 'Sharq', provider: 'eventat'),
  'sci': Venue('The Scientific Center', 'المركز العلمي', 29.3415, 48.0935, 'Salmiya', provider: 'eventat'),
  'kabd': Venue('Kabd desert (demo camp)', 'بر كبد (مخيم تجريبي)', 29.1500, 47.7500, 'Kabd', provider: 'eventat'),
};

const areaAr = <String, String>{
  'Dasman': 'دسمان', 'Kuwait City': 'مدينة الكويت', 'Gulf Road': 'شارع الخليج', 'Sharq': 'شرق',
  'Salmiya': 'السالمية', 'Jabriya': 'الجابرية', 'Qadsiya': 'القادسية', 'Al Rai': 'الري', 'Zahra': 'الزهراء',
  'Messila': 'المسيلة', 'Kabd': 'كبد', 'Failaka': 'فيلكا', 'Salwa': 'سلوى', 'Shuwaikh': 'الشويخ',
  'Ardiya': 'العارضية', 'Mishref': 'مشرف',
};

Listing _ev({
  required String id,
  required String en,
  required String ar,
  required String cat,
  required List<String> tags,
  required String venue,
  required int dur,
  List<int>? days,
  required List<int> times,
  required double price,
  double? child,
  int minAge = 0,
  String lang = '',
  bool indoor = true,
  bool acc = true,
  double pop = .6,
  List<int>? months,
  required String motif,
  required String desc,
  required String descAr,
  bool demo = true,
  String? imageUrl,
}) {
  final v = venues[venue]!;
  return Listing(
    id: id, type: ListingType.event, en: en, ar: ar, cat: cat, tags: tags, area: v.area,
    lat: v.lat, lng: v.lng, dur: dur, price: price, child: child, minAge: minAge, indoor: indoor,
    acc: acc, pop: pop, months: months, motif: motif, desc: desc, descAr: descAr, demo: demo,
    venue: venue, days: days, times: times, lang: lang, provider: v.provider,
    bookUrl: v.provider == null ? null : providers[v.provider]!.url,
    imageUrl: imageUrl,
  );
}

final List<Listing> places = [
  Listing(id: 'kuwait-towers', type: ListingType.place, en: 'Kuwait Towers', ar: 'أبراج الكويت', cat: 'architecture', tags: ['architecture', 'photography', 'culture'], area: 'Dasman', lat: 29.3897, lng: 48.0036, dur: 75, price: 3, child: 1.5, indoor: false, pop: .95, hours: h(540, 1380), motif: 'towers', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Kuwait_Towers_-_Main_Tower_crop.jpg/640px-Kuwait_Towers_-_Main_Tower_crop.jpg', desc: 'The 1979 landmark on Gulf Road, with a revolving viewing sphere over the city and the bay.', descAr: 'معلم عام ١٩٧٩ على شارع الخليج، بكرة مشاهدة دوارة تطل على المدينة والجون.'),
  Listing(id: 'grand-mosque', type: ListingType.place, en: 'Grand Mosque visitor tour', ar: 'جولة المسجد الكبير', cat: 'architecture', tags: ['architecture', 'culture', 'heritage'], area: 'Kuwait City', lat: 29.3740, lng: 47.9800, dur: 60, price: 0, pop: .85, hours: h(540, 900), except: {5: []}, motif: 'dome', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Grand_Mosque_Kuwait_City_%28Masjid_Al-Kabir%29.jpg/640px-Grand_Mosque_Kuwait_City_%28Masjid_Al-Kabir%29.jpg', desc: "Guided tours of Kuwait's largest mosque. Modest dress required; abayas provided for women.", descAr: 'جولات مرشدة في أكبر مساجد الكويت. يلزم اللباس المحتشم وتتوفر العباءات للنساء.'),
  Listing(id: 'souq-mubarakiya', type: ListingType.place, en: 'Souq Al-Mubarakiya', ar: 'سوق المباركية', cat: 'markets', tags: ['markets', 'heritage', 'culture', 'shopping', 'photography', 'kuwaiti_food'], area: 'Kuwait City', lat: 29.3700, lng: 47.9733, dur: 90, price: 0, indoor: false, pop: .95, hours: h(540, 1380), motif: 'arch', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Mubarakiyya_Market.jpg/640px-Mubarakiyya_Market.jpg', desc: 'One of the oldest markets in Kuwait: dates, spices, oud and grill restaurants.', descAr: 'من أقدم أسواق الكويت: تمور وبهارات وعود ومطاعم مشويات.'),
  Listing(id: 'sadu-house', type: ListingType.place, en: 'Sadu House', ar: 'بيت السدو', cat: 'heritage', tags: ['heritage', 'art', 'culture'], area: 'Gulf Road', lat: 29.3833, lng: 47.9861, dur: 45, price: 0, pop: .7, hours: h(540, 1140), except: {5: []}, motif: 'sadu', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Sadu_House_Kuwait.jpg/640px-Sadu_House_Kuwait.jpg', desc: 'A house devoted to Al Sadu, the geometric Bedouin weaving tradition.', descAr: 'بيت مخصص لنسيج السدو البدوي بزخارفه الهندسية.'),
  Listing(id: 'national-museum', type: ListingType.place, en: 'Kuwait National Museum', ar: 'متحف الكويت الوطني', cat: 'museums', tags: ['museums', 'heritage', 'culture'], area: 'Gulf Road', lat: 29.3824, lng: 47.9832, dur: 90, price: 0, pop: .7, hours: h(510, 1230), except: {5: h(960, 1230)}, motif: 'frame', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Kuwait_National_Museum.jpg/640px-Kuwait_National_Museum.jpg', desc: 'Archaeology and the story of Kuwait before oil.', descAr: 'آثار وحكاية الكويت قبل النفط.'),
  Listing(id: 'ascc', type: ListingType.place, en: 'Sheikh Abdullah Al-Salem Cultural Centre', ar: 'مركز الشيخ عبدالله السالم الثقافي', cat: 'museums', tags: ['museums', 'family', 'kids', 'art'], area: 'Dasman', lat: 29.3612, lng: 47.9990, dur: 180, price: 3, child: 2, pop: .9, hours: h(540, 1260), motif: 'frame', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/Sheikh_Abdullah_Al-Salem_Cultural_Centre_Kuwait.jpg/640px-Sheikh_Abdullah_Al-Salem_Cultural_Centre_Kuwait.jpg', desc: 'A large museum district: natural history, science, space and Islamic art.', descAr: 'مجمع متاحف كبير: التاريخ الطبيعي والعلوم والفضاء والفنون الإسلامية.'),
  Listing(id: 'shaheed-park', type: ListingType.place, en: 'Al Shaheed Park', ar: 'حديقة الشهيد', cat: 'family', tags: ['family', 'photography', 'wellness', 'kids'], area: 'Sharq', lat: 29.3657, lng: 47.9888, dur: 75, price: 0, indoor: false, pop: .85, hours: h(360, 1320), motif: 'leaf', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/Pathway_with_lights_and_trees_in_Al_Shaheed_Park%2C_Kuwait.jpg/960px-Pathway_with_lights_and_trees_in_Al_Shaheed_Park%2C_Kuwait.jpg', desc: 'A long green park in the city centre with lakes and walking paths.', descAr: 'حديقة خضراء وسط المدينة فيها بحيرات وممرات مشي.'),
  Listing(id: 'scientific-center', type: ListingType.place, en: 'The Scientific Center', ar: 'المركز العلمي', cat: 'family', tags: ['family', 'kids', 'museums'], area: 'Salmiya', lat: 29.3415, lng: 48.0935, dur: 120, price: 4, child: 3, pop: .85, hours: h(540, 1260), motif: 'waves', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Scientific_Center_Kuwait.jpg/640px-Scientific_Center_Kuwait.jpg', desc: 'Aquarium and discovery halls on the Salmiya waterfront.', descAr: 'أحواض مائية وقاعات اكتشاف على واجهة السالمية.'),
  Listing(id: 'tareq-rajab', type: ListingType.place, en: 'Tareq Rajab Museum', ar: 'متحف طارق رجب', cat: 'museums', tags: ['museums', 'art', 'heritage'], area: 'Jabriya', lat: 29.3220, lng: 48.0270, dur: 75, price: 2, child: 1, acc: false, pop: .6, hours: h(540, 1140), except: {5: []}, motif: 'frame', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Jabriya_Tareq_Rajab_Museum_of_Calligraphy_1.jpg/800px-Jabriya_Tareq_Rajab_Museum_of_Calligraphy_1.jpg', desc: 'A private collection of Islamic art, calligraphy and jewellery.', descAr: 'مجموعة خاصة من الفنون الإسلامية والخط والمجوهرات.'),
  Listing(id: 'avenues', type: ListingType.place, en: 'The Avenues', ar: 'الأفنيوز', cat: 'shopping', tags: ['shopping', 'luxury', 'family', 'cafes'], area: 'Al Rai', lat: 29.3036, lng: 47.9365, dur: 150, price: 0, pop: .95, hours: h(600, 1380), except: {5: h(780, 1380)}, motif: 'bag', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/The_Avenues_Kuwait.jpg/800px-The_Avenues_Kuwait.jpg', desc: 'One of the largest malls in the region, with a luxury district.', descAr: 'من أكبر المجمعات في المنطقة، مع منطقة فاخرة.'),
  Listing(id: 'mall-360', type: ListingType.place, en: '360 Mall', ar: 'مجمع ٣٦٠', cat: 'shopping', tags: ['shopping', 'luxury'], area: 'Zahra', lat: 29.2697, lng: 47.9907, dur: 120, price: 0, pop: .75, hours: h(600, 1380), except: {5: h(780, 1380)}, motif: 'bag', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/360_Mall_in_Kuwait_City.jpg/800px-360_Mall_in_Kuwait_City.jpg', desc: 'An upscale mall known for its indoor vertical garden.', descAr: 'مجمع راقٍ معروف بحديقته العمودية الداخلية.'),
  Listing(id: 'marina-crescent', type: ListingType.place, en: 'Marina Crescent waterfront', ar: 'هلال المارينا', cat: 'cafes', tags: ['cafes', 'desserts', 'photography', 'beaches'], area: 'Salmiya', lat: 29.3420, lng: 48.0700, dur: 75, price: 0, indoor: false, pop: .7, hours: h(480, 1440), motif: 'waves', imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/09/25/7f/a8/tche-tche-cafe.jpg?w=1200&h=900&s=1', desc: 'A seafront promenade lined with cafés.', descAr: 'ممشى بحري تصطف عليه المقاهي.'),
  Listing(id: 'green-island', type: ListingType.place, en: 'Green Island', ar: 'الجزيرة الخضراء', cat: 'family', tags: ['family', 'wellness', 'kids'], area: 'Dasman', lat: 29.3815, lng: 48.0095, dur: 60, price: .5, child: .25, indoor: false, pop: .55, hours: h(480, 1320), motif: 'leaf', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Green_island_kuwait.JPG/800px-Green_island_kuwait.JPG', desc: 'A small island park off Gulf Road with play areas.', descAr: 'جزيرة صغيرة قبالة شارع الخليج فيها ألعاب.'),
  Listing(id: 'messila-beach', type: ListingType.place, en: 'Messila beach', ar: 'شاطئ المسيلة', cat: 'beaches', tags: ['beaches', 'wellness'], area: 'Messila', lat: 29.2685, lng: 48.0980, dur: 120, price: 0, indoor: false, acc: false, pop: .55, hours: h(420, 1140), motif: 'waves', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Low_Tide_Messila_beach_Kuwait.jpg/800px-Low_Tide_Messila_beach_Kuwait.jpg', desc: 'A sandy stretch south of Salmiya.', descAr: 'شاطئ رملي جنوب السالمية.'),
  Listing(id: 'desert-camp', type: ListingType.place, en: 'Desert camp evening', ar: 'أمسية في مخيم بري', cat: 'desert', tags: ['desert', 'adventure', 'culture', 'photography'], area: 'Kabd', lat: 29.15, lng: 47.75, dur: 240, price: 35, child: 20, indoor: false, acc: false, pop: .8, months: [11, 12, 1, 2, 3], hours: h(900, 1380), motif: 'dunes', demo: true, imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Camels_in_the_Kuwaiti_desert.jpg/800px-Camels_in_the_Kuwaiti_desert.jpg', desc: 'Camp season in the cooler months: dunes, Arabic coffee, dinner by the fire.', descAr: 'موسم المخيمات في الأشهر الباردة: كثبان وقهوة عربية وعشاء حول النار.'),
  Listing(id: 'failaka', type: ListingType.place, en: 'Failaka Island day trip', ar: 'رحلة إلى جزيرة فيلكا', cat: 'heritage', tags: ['heritage', 'adventure', 'beaches', 'photography'], area: 'Failaka', lat: 29.44, lng: 48.33, dur: 360, price: 12, child: 6, indoor: false, acc: false, pop: .7, hours: h(480, 1080), motif: 'arch', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Failaka_Island_Kuwait.jpg/640px-Failaka_Island_Kuwait.jpg', desc: 'Ferry to the island for ancient ruins and empty beaches.', descAr: 'عبّارة إلى الجزيرة لزيارة الآثار والشواطئ.'),
  Listing(id: 'friday-market', type: ListingType.place, en: 'Friday Market', ar: 'سوق الجمعة', cat: 'markets', tags: ['markets', 'shopping', 'photography'], area: 'Al Rai', lat: 29.2990, lng: 47.9500, dur: 90, price: 0, indoor: false, acc: false, pop: .6, hours: const [], except: {5: h(480, 1080), 6: h(480, 1080)}, motif: 'arch', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Friday_market_people_up.jpg/800px-Friday_market_people_up.jpg', desc: 'Weekend flea market: carpets, antiques and plants.', descAr: 'سوق شعبي في نهاية الأسبوع: سجاد وتحف ونباتات.'),
  // --- Real places confirmed from public sources ---
  // Al Bahhar Historical Village — open 10 AM–10:30 PM daily (confirmed: evendo.com / kupi.com)
  Listing(id: 'al-bahhar', type: ListingType.place, en: 'Al Bahhar Historical Village', ar: 'قرية البحار التاريخية', cat: 'heritage', tags: ['heritage', 'culture', 'family', 'photography'], area: 'Dasman', lat: 29.3900, lng: 47.9980, dur: 90, price: 2, child: 1, indoor: false, acc: true, pop: .78, hours: h(600, 1350), motif: 'arch', demo: true, desc: 'Open-air recreation of a pre-oil Kuwaiti settlement on Arabian Gulf Street: pearl diving demonstrations, dhow-building and Bedouin craft workshops.', descAr: 'قرية كويتية تراثية مفتوحة في الهواء الطلق على شارع الخليج: عروض الغوص على اللؤلؤ وبناء الذو وورش الحرف البدوية.'),
  // Kuwait International Book Fair — held annually in November at Mishref Fairgrounds
  // 48th edition (2025): 19–29 Nov, 611 publishers from 33 countries, 287,000+ titles (source: xinhua, nccal.gov.kw)
  Listing(id: 'book-fair', type: ListingType.place, en: 'Kuwait International Book Fair', ar: 'معرض الكويت الدولي للكتاب', cat: 'culture', tags: ['culture', 'art', 'festivals', 'family'], area: 'Mishref', lat: 29.2803, lng: 48.0612, dur: 240, price: 0, indoor: true, acc: true, pop: .85, months: [11], hours: h(600, 1380), motif: 'frame', demo: false, desc: 'One of the Arab world\'s largest book fairs — 600+ publishers from 33 countries and 280,000+ titles across three halls at the Mishref Fairgrounds. Runs annually in November (~10 days).', descAr: 'من أكبر معارض الكتاب في العالم العربي — أكثر من ٦٠٠ دار نشر من ٣٣ دولة وأكثر من ٢٨٠٠٠٠ عنوان في ثلاث قاعات بمعارض الكويت في مشرف. يقام سنوياً في نوفمبر لنحو ١٠ أيام.'),
  // restaurants
  // --- Real restaurants confirmed on OpenTable (opentable.com/kuwait) ---
  //
  // Sintoho — Japanese/Asian, 21st floor, Four Seasons Hotel Kuwait (Burj Alshaya)
  // Hours: Mon–Sat 5 PM–midnight. Closed Sunday. (source: fourseasons.com/kuwait)
  // Price: KD 40–80 pp confirmed via review; OpenTable: opentable.com/r/sintoho-al-mirqab-1
  Listing(id: 'sintoho', type: ListingType.restaurant, en: 'Sintoho', ar: 'سينتوهو',
      cat: 'fine_dining', tags: ['fine_dining', 'luxury'],
      area: 'Kuwait City', lat: 29.3730, lng: 47.9762,
      dur: 120, price: 45, indoor: true, acc: true, pop: .82,
      meals: ['d'], hours: h(1020, 1440), except: {0: []},
      motif: 'plate', demo: true,
      provider: 'opentable', bookUrl: 'https://www.opentable.com/r/sintoho-al-mirqab-1',
      imageUrl: 'https://bazaar.town/wp-content/uploads/2021/05/1_KUW_437_1.jpg',
      photos: [
        'https://bazaar.town/wp-content/uploads/2021/05/5_KUW_577_1.jpg',
        'https://bazaar.town/wp-content/uploads/2021/05/3_KUW_305_1.jpg',
      ],
      menuUrl: 'https://www.fourseasons.com/kuwait/dining/restaurants/sintoho/',
      desc: 'Japanese and Southeast Asian at the 21st floor of the Four Seasons Hotel — robata grill, sushi and teppanyaki with panoramic city views. Reserve on OpenTable.',
      descAr: 'مطبخ ياباني وجنوب شرق آسيوي في الطابق ٢١ من فندق فور سيزونز — مشاوي روباتا وسوشي وتيباياكي مع إطلالات بانورامية. الحجز عبر OpenTable.'),
  //
  // Dai Forni — Italian, 21st floor, Four Seasons Hotel Kuwait (Burj Alshaya)
  // Price: $31–50 pp on OpenTable ≈ KD 10–15. (source: opentable.com/r/dai-forni-al-mirqab)
  Listing(id: 'dai-forni', type: ListingType.restaurant, en: 'Dai Forni', ar: 'داي فورني',
      cat: 'fine_dining', tags: ['fine_dining', 'luxury'],
      area: 'Kuwait City', lat: 29.3730, lng: 47.9762,
      dur: 90, price: 12, indoor: true, acc: true, pop: .78,
      meals: ['l', 'd'], hours: h(720, 1380),
      motif: 'plate', demo: false,
      provider: 'opentable', bookUrl: 'https://www.opentable.com/r/dai-forni-al-mirqab',
      imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/11/cc/0a/02/dai-forni-restaurant.jpg?w=1200&h=900&s=1',
      photos: [
        'https://bazaar.town/wp-content/uploads/2021/05/6_KUW_650_1.jpg',
        'https://bazaar.town/wp-content/uploads/2021/05/4_KUW_389_1.jpg',
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/30/00/f9/98/caption.jpg?w=1200&h=900&s=1',
      ],
      menuUrl: 'https://www.fourseasons.com/kuwait/dining/restaurants/dai-forni/',
      desc: 'Wood-fired pizzas and handmade pasta from three giant copper-sheathed ovens on the 21st floor of the Four Seasons. Casual yet elegant. Reserve on OpenTable.',
      descAr: 'بيتزا من الفرن الحطبي ومعكرونة يدوية من ثلاثة أفران نحاسية ضخمة في الطابق ٢١ من فور سيزونز. أجواء غير رسمية وأنيقة. الحجز عبر OpenTable.'),
  //
  // Jamawar Indian Restaurant — Salmiya branch (also at Holiday Inn Al Thuraya)
  // Hours: 12 PM–11 PM daily. Price: $39–81 pp on OpenTable ≈ KD 12–25.
  // (source: opentable.com/r/jamawar-indian-restaurant-kuwait-city)
  Listing(id: 'jamawar', type: ListingType.restaurant, en: 'Jamawar Indian Restaurant', ar: 'جاماوار للمطبخ الهندي',
      cat: 'fine_dining', tags: ['fine_dining'],
      area: 'Salmiya', lat: 29.3360, lng: 48.0710,
      dur: 90, price: 15, indoor: true, acc: true, pop: .88,
      meals: ['l', 'd'], hours: h(720, 1380),
      motif: 'plate', demo: false,
      provider: 'opentable', bookUrl: 'https://www.opentable.com/r/jamawar-indian-restaurant-kuwait-city',
      imageUrl: 'https://qcqxcffgfdsqfrwwvabh.supabase.co/storage/v1/object/public/restaurants/jamawar-indian-restaurant-salmiya/images/jamawar-indian-restaurant-salmiya-warm-lighting-wooden-interior-dining-room.jpg',
      photos: [
        'https://qcqxcffgfdsqfrwwvabh.supabase.co/storage/v1/object/public/restaurants/jamawar-indian-restaurant-salmiya/images/jamawar-indian-restaurant-salmiya-spicy-chicken-tikka-side-salad.jpg',
        'https://qcqxcffgfdsqfrwwvabh.supabase.co/storage/v1/object/public/restaurants/jamawar-indian-restaurant-salmiya/images/jamawar-indian-restaurant-salmiya-butter-chicken-naan-samosas-dining-table.jpg',
        'https://qcqxcffgfdsqfrwwvabh.supabase.co/storage/v1/object/public/restaurants/jamawar-indian-restaurant-salmiya/images/jamawar-indian-restaurant-salmiya-biryani-copper-pot-lemon-soda.jpg',
        'https://qcqxcffgfdsqfrwwvabh.supabase.co/storage/v1/object/public/restaurants/jamawar-indian-restaurant-salmiya/images/jamawar-indian-restaurant-salmiya-copper-thali-set-indian-dishes.jpg',
      ],
      desc: 'Authentic Indian restaurant consistently rated among Kuwait City\'s top tables — kebabs, biryani and slow-cooked curries. Rated 4.9 on OpenTable.',
      descAr: 'مطعم هندي أصيل يُصنَّف باستمرار ضمن أفضل مطاعم الكويت — كباب وبيريانى وكاري مطبوخ ببطء. تقييم ٤.٩ على OpenTable.'),
  //
  // Shabestan Iranian Restaurant — location: Crowne Plaza Kuwait, Shaab
  // Hours: 12 PM–11 PM daily. Price: $39–81 pp ≈ KD 12–25.
  // Ranked #14 of 564 restaurants in Kuwait City on TripAdvisor (2025).
  // (source: opentable.com/r/shabestan-iranian-restaurant-kuwait-city)
  Listing(id: 'shabestan', type: ListingType.restaurant, en: 'Shabestan Iranian Restaurant', ar: 'شبستان للمطبخ الإيراني',
      cat: 'fine_dining', tags: ['fine_dining'],
      area: 'Salmiya', lat: 29.3510, lng: 48.0780,
      dur: 90, price: 14, indoor: true, acc: true, pop: .84,
      meals: ['l', 'd'], hours: h(720, 1380),
      motif: 'plate', demo: false,
      provider: 'opentable', bookUrl: 'https://www.opentable.com/r/shabestan-iranian-restaurant-kuwait-city',
      imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0e/98/75/ff/shabestan-iranian-restaurant.jpg?w=1200&h=900&s=1',
      photos: [
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0e/98/6a/53/shabestan-iranian-restaurant.jpg?w=1200&h=900&s=1',
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/14/26/d5/e9/nargesi-kashkeh-e-badenjan.jpg?w=1200&h=900&s=1',
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/16/60/80/ac/lamb-very-tasty-and-well.jpg?w=1200&h=900&s=1',
      ],
      menuUrl: 'https://www.talabat.com/kuwait/shabestan',
      desc: 'Authentic Persian cuisine — freshly prepared grills and home-style dishes. Rated #14 of 564 Kuwait City restaurants on TripAdvisor. Reserve on OpenTable.',
      descAr: 'مطبخ إيراني أصيل — مشاوي طازجة وأطباق منزلية الطراز. مصنّف رقم ١٤ من ٥٦٤ مطعماً في الكويت على TripAdvisor. الحجز عبر OpenTable.'),
  //
  Listing(id: 'freej-swaileh', type: ListingType.restaurant, en: 'Freej Swaileh', ar: 'فريج صويلح',
      cat: 'kuwaiti_food', tags: ['kuwaiti_food', 'culture'],
      area: 'Salmiya', lat: 29.3350, lng: 48.0650,
      dur: 75, price: 6, pop: .85, meals: ['b', 'l', 'd'], hours: h(420, 1440), motif: 'plate',
      imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/12/3f/44/6f/ground-floor-dining-room.jpg?w=1200&h=900&s=1',
      logoUrl: 'https://static.wixstatic.com/media/b94ea9_8b0f8df6625143ef8bab5a72c546d41c~mv2.png',
      photos: [
        'https://static.wixstatic.com/media/b94ea9_864b54a7acdf4b04a2df48147338abd2~mv2.jpeg',
        'https://static.wixstatic.com/media/b94ea9_819d3a98ada844f692f5cfe0f46fd69f~mv2.jpg',
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/16/82/32/df/chicken-makboos.jpg?w=1200&h=900&s=1',
        'https://static.wixstatic.com/media/b94ea9_d7e500aca89746e29139fdd900971306~mv2.jpeg',
      ],
      menuUrl: 'https://www.freejswalieh.com/menu',
      desc: 'Home-style Kuwaiti dishes such as machboos.', descAr: 'أطباق كويتية منزلية مثل المچبوس.'),
  Listing(id: 'dar-hamad', type: ListingType.restaurant, en: 'Dar Hamad', ar: 'دار حمد',
      cat: 'kuwaiti_food', tags: ['kuwaiti_food', 'fine_dining', 'culture'],
      area: 'Sharq', lat: 29.3870, lng: 47.9990,
      dur: 90, price: 16, pop: .75, meals: ['l', 'd'], hours: h(720, 1410), motif: 'plate',
      imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/24/67/ee/74/inside-the-restaurant.jpg?w=1200&h=900&s=1',
      logoUrl: 'https://static.zyda.com/b6bxfcpjnk9bvpycf9iwe3yb72rc',
      photos: [
        'https://static.zyda.com/variants/ec26hobwy128127xpv4oa6f1hfs5/327db254c782280f8981701dd59d82fc59ea5221ea385e9afd00182eea055f79',
        'https://static.zyda.com/variants/eg794342irk3odnjjtt5t6ll6v9n/327db254c782280f8981701dd59d82fc59ea5221ea385e9afd00182eea055f79',
        'https://static.zyda.com/variants/0x3b1fr3oewdmdxhjpbxjw6fdm7s/327db254c782280f8981701dd59d82fc59ea5221ea385e9afd00182eea055f79',
        'https://static.zyda.com/variants/8xw69pdlt34j10gzxl2odzpn4iwx/327db254c782280f8981701dd59d82fc59ea5221ea385e9afd00182eea055f79',
      ],
      menuUrl: 'https://www.orderdarhamad.com/en',
      desc: 'Kuwaiti and Gulf cooking near the waterfront.', descAr: 'مطبخ كويتي وخليجي قرب الواجهة البحرية.'),
  Listing(id: 'mais-alghanim', type: ListingType.restaurant, en: 'Mais Alghanim', ar: 'ميس الغانم',
      cat: 'kuwaiti_food', tags: ['kuwaiti_food'],
      area: 'Dasman', lat: 29.3880, lng: 48.0025,
      dur: 75, price: 9, indoor: false, pop: .8, meals: ['l', 'd'], hours: h(720, 1440), motif: 'plate',
      imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0e/79/d3/8d/interior.jpg?w=1200&h=900&s=1',
      logoUrl: 'https://www.maisalghanim.com/wp-content/uploads/2019/08/logo.png',
      photos: [
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/08/d0/48/0a/mais-alghanim.jpg?w=1200&h=1200&s=1',
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/14/06/a8/54/safary.jpg?w=1200&h=-1&s=1',
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/14/74/7e/54/photo2jpg.jpg?w=1200&h=900&s=1',
      ],
      menuUrl: 'https://qrmenu.maisalghanim.com/?b=5948',
      desc: 'A long-running Arabic grill by the sea near Kuwait Towers.', descAr: 'مطعم مشويات عربي عريق على البحر قرب الأبراج.'),
  Listing(id: 'souq-cafe', type: ListingType.restaurant, en: 'Karak & gahwa in the souq', ar: 'كرك وقهوة في السوق', cat: 'cafes', tags: ['cafes', 'kuwaiti_food', 'culture'], area: 'Kuwait City', lat: 29.3705, lng: 47.9740, dur: 45, price: 2, indoor: false, pop: .7, meals: ['b', 's'], hours: h(420, 1380), motif: 'cup', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Karak_tea_in_Kuwait_2.jpg/500px-Karak_tea_in_Kuwait_2.jpg', desc: 'Karak tea and Arabic coffee inside Souq Al-Mubarakiya.', descAr: 'شاي كرك وقهوة عربية داخل سوق المباركية.'),
  Listing(id: 'fine-waterfront', type: ListingType.restaurant, en: 'Waterfront fine dining', ar: 'مطعم راقٍ على البحر', cat: 'fine_dining', tags: ['fine_dining'], area: 'Salmiya', lat: 29.3445, lng: 48.0880, dur: 105, price: 38, pop: .6, meals: ['d'], hours: h(1140, 1410), motif: 'plate', demo: true, imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Sunset_from_Umm_al_maradem_island_Kuwait.jpg/960px-Sunset_from_Umm_al_maradem_island_Kuwait.jpg', desc: 'Tasting menu with Gulf views. Demo listing.', descAr: 'قائمة تذوق بإطلالة على الخليج. قائمة تجريبية.'),
  Listing(id: 'kw-breakfast', type: ListingType.restaurant, en: 'Kuwaiti breakfast house', ar: 'بيت الريوق الكويتي', cat: 'kuwaiti_food', tags: ['kuwaiti_food', 'culture'], area: 'Kuwait City', lat: 29.3720, lng: 47.9840, dur: 60, price: 4, pop: .6, meals: ['b'], hours: h(390, 720), motif: 'plate', demo: true, imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Balaleet_2019.jpg/960px-Balaleet_2019.jpg', desc: 'Balaleet, chami cheese and fresh bread. Demo listing.', descAr: 'بلاليط وجامي وخبز طازج. قائمة تجريبية.'),
  Listing(id: 'seafood-grill', type: ListingType.restaurant, en: 'Seafood grill by the fish market', ar: 'مشويات بحرية قرب سوق السمك', cat: 'kuwaiti_food', tags: ['kuwaiti_food'], area: 'Sharq', lat: 29.3840, lng: 48.0010, dur: 75, price: 11, veg: false, pop: .55, meals: ['l', 'd'], hours: h(720, 1410), motif: 'plate', demo: true, imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/DSCF0708_Crispy_golden-brown_whole_fish_grilled_and_stacked_on_a_tray_ready_to_serve_at_a_bustling_night_market.jpg/960px-DSCF0708_Crispy_golden-brown_whole_fish_grilled_and_stacked_on_a_tray_ready_to_serve_at_a_bustling_night_market.jpg', desc: "Pick the day's catch and have it grilled. Demo listing.", descAr: 'اختر صيد اليوم واطلب شويه. قائمة تجريبية.'),
];

final List<Listing> events = [
  _ev(id: 'ev-strings', en: 'Al Ekhwa Band — Amphitheatre', ar: 'فرقة الإخوة — الأمفيثياتر',
      cat: 'concerts', tags: ['concerts', 'live_music', 'culture'], venue: 'jacc',
      dur: 120, days: [4], times: [1230], price: 12, minAge: 6,
      lang: 'Arabic', pop: .80, months: [11], motif: 'stage',
      imageUrl: 'https://www.jacc-kw.com/core/wp-content/uploads/2026/09/Website_Eventname_Al_Ekhwa_Band_EN_606.jpg',
      desc: 'Al Ekhwa Band perform Gulf classics under the open sky at the JACC Amphitheatre. Nov 6, 8:30 PM.',
      descAr: 'فرقة الإخوة تقدم روائع الطرب الخليجي في الأمفيثياتر المفتوح بمركز جابر. ٦ نوفمبر، ٨:٣٠ م.',
      demo: true),
  _ev(id: 'ev-arena-concert', en: 'Headline concert at The Arena', ar: 'حفل رئيسي في ذا أرينا', cat: 'concerts', tags: ['concerts', 'live_music'], venue: 'arena', dur: 150, days: [5], times: [1290], price: 25, lang: 'Arabic', pop: .9, motif: 'stage', desc: 'Example listing for an Arena concert.', descAr: 'مثال لحفل في ذا أرينا.'),
  _ev(id: 'ev-play', en: 'Kuwaiti comedy play', ar: 'مسرحية كوميدية كويتية', cat: 'theatre', tags: ['theatre', 'comedy', 'culture'], venue: 'theatre', dur: 120, days: [4, 5, 6], times: [1260], price: 12, minAge: 8, lang: 'Arabic', pop: .75, motif: 'stage', imageUrl: 'https://kuwaittimes.com/kuwaittimes/uploads/images/2026/09/17/444909.jpg', desc: 'A local comedy in Kuwaiti dialect.', descAr: 'مسرحية كوميدية باللهجة الكويتية.'),
  _ev(id: 'ev-musical', en: 'Family musical', ar: 'مسرحية غنائية للعائلة', cat: 'theatre', tags: ['theatre', 'family', 'kids'], venue: 'jacc', dur: 90, days: [5, 6], times: [1020], price: 8, child: 5, minAge: 3, lang: 'Arabic & English', pop: .7, motif: 'stage', imageUrl: 'https://www.jacc-kw.com/core/wp-content/uploads/2026/09/Website_Eventname_Whispers_of_the_Keys_EN_598.jpg', desc: 'A bilingual musical for children 3 and up.', descAr: 'مسرحية غنائية ثنائية اللغة للأطفال من سن ٣.'),
  _ev(id: 'ev-football', en: 'Kuwaiti league match', ar: 'مباراة الدوري الكويتي', cat: 'sports', tags: ['sports', 'football'], venue: 'stadium', dur: 120, days: [4, 5], times: [1110], price: 2, child: 1, indoor: false, pop: .6, motif: 'ball', imageUrl: 'https://kuwait-fa.org/wp-content/uploads/2026/09/kfa-ticket-promo-kuwait-iraq-jeddah.jpg', desc: 'A league fixture under the floodlights.', descAr: 'مباراة في الدوري تحت الأضواء.'),
  _ev(id: 'ev-film-drama', en: 'Now showing: Arabic drama', ar: 'يعرض الآن: دراما عربية', cat: 'cinema', tags: ['cinema'], venue: 'cinema', dur: 130, times: [960, 1140, 1320], price: 4.5, minAge: 15, lang: 'Arabic, English subtitles', pop: .5, motif: 'film', imageUrl: 'https://media0106.elcinema.com/uploads/_315x420_7ee673dad6a9cc695929303bf427bb2b1fe0481082b1e95d3d98f9973957f60b.jpg', desc: 'Example screening. Real showtimes come from Cinescape.', descAr: 'عرض تجريبي. المواعيد الحقيقية من سينسكيب.'),
  _ev(id: 'ev-film-family', en: 'Now showing: family animation', ar: 'يعرض الآن: فيلم رسوم عائلي', cat: 'cinema', tags: ['cinema', 'family', 'kids'], venue: 'cinema', dur: 105, times: [900, 1080], price: 4.5, child: 3.5, lang: 'English, Arabic dub', pop: .5, motif: 'film', imageUrl: 'https://media0106.elcinema.com/uploads/_315x420_839ba1eaddd84d851ddd046ff96fcffb0c1c840be888982096de0876ee5479c7.jpg', desc: 'Example family screening.', descAr: 'عرض عائلي تجريبي.'),
  _ev(id: 'ev-sadu-workshop', en: 'Sadu weaving workshop', ar: 'ورشة نسيج السدو', cat: 'culture', tags: ['culture', 'heritage', 'art'], venue: 'sadu', dur: 120, days: [6], times: [600], price: 10, minAge: 10, lang: 'English & Arabic', pop: .6, motif: 'sadu', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/d/d6/Textile_Al_Sadu%2C_Egypte%2C_collection_priv%C3%A9e_de_Ariane_Mawaffo.jpg', desc: 'Try the loom with a weaver.', descAr: 'جرّب النول مع حائكة.'),
  _ev(id: 'ev-cruise', en: 'Sunset dhow cruise', ar: 'رحلة غروب على سفينة شراعية', cat: 'heritage', tags: ['heritage', 'photography', 'culture'], venue: 'marina', dur: 90, times: [1050], price: 20, child: 10, indoor: false, acc: false, pop: .75, motif: 'waves', imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1c/66/42/e6/approaching-the-souq.jpg?w=1200&h=1200&s=1', desc: 'A traditional boat along the bay at dusk.', descAr: 'قارب تقليدي في الجون عند الغروب.'),
  // --- Real confirmed events from JACC (jacc-kw.com) season 2025 ---
  // Elissa — Oct 2 2025 (Thursday), 9:30 PM. Ticket price not publicly confirmed → demo: true
  _ev(id: 'ev-elissa-25', en: 'Elissa Live — National Theatre', ar: 'إليسا — المسرح الوطني',
      cat: 'concerts', tags: ['concerts', 'live_music'], venue: 'jacc',
      dur: 120, days: [4], times: [1290], price: 20, minAge: 6,
      lang: 'Arabic', pop: .92, months: [10], motif: 'stage',
      imageUrl: 'https://s3.eu-central-1.amazonaws.com/dev-jaccimages/image/Poster_Image_Elissa_EN_573.jpg',
      desc: 'Lebanese superstar Elissa performs at the JACC National Theatre as part of the centre\'s 10th anniversary celebrations.',
      descAr: 'النجمة اللبنانية إليسا تحيي حفلها في المسرح الوطني بمركز جابر احتفالاً بمرور ١٠ سنوات على افتتاحه.',
      demo: true),
  // Blue — Oct 22 & 23 2025 (Wed & Thu), 9:30 PM. 25th anniversary world tour.
  _ev(id: 'ev-blue-25', en: 'Blue — 25th Anniversary World Tour', ar: 'بلو — جولة الذكرى الـ٢٥',
      cat: 'concerts', tags: ['concerts', 'live_music'], venue: 'jacc',
      dur: 120, days: [3, 4], times: [1290], price: 20, minAge: 6,
      lang: 'English', pop: .85, months: [10], motif: 'stage',
      imageUrl: 'https://www.jacc-kw.com/core/wp-content/uploads/2026/08/Website_Eventname_Blue_en_EN_596.jpg',
      desc: 'British pop group Blue return to Kuwait for two nights at the National Theatre as part of their 25th anniversary world tour.',
      descAr: 'الفرقة البريطانية بلو تعود إلى الكويت لليلتين في المسرح الوطني ضمن جولتهم العالمية بمناسبة الذكرى الـ٢٥.',
      demo: true),
  // Beatles Symphonic Fantasy — Oct 30 2025 (Thursday), 9:30 PM.
  _ev(id: 'ev-beatles-symph', en: 'Beatles Symphonic Fantasy', ar: 'بيتلز سيمفونيك فانتازي',
      cat: 'concerts', tags: ['concerts', 'live_music'], venue: 'jacc',
      dur: 120, days: [4], times: [1290], price: 15, minAge: 5,
      lang: 'Instrumental', pop: .80, months: [10], motif: 'stage',
      imageUrl: 'https://s3.eu-central-1.amazonaws.com/dev-jaccimages/image/Poster_Image_The_Beatles_EN_593.jpg',
      desc: 'The greatest hits of The Beatles reimagined as full orchestral arrangements — a symphonic celebration of the Fab Four.',
      descAr: 'أعظم أغاني فرقة البيتلز في ترتيبات أوركسترالية كاملة — احتفاء سيمفونياً بالرباعي الأسطوري.',
      demo: true),
  // Dandana with Musaed Al-Balushi — Nov 3 2025 (Monday), 8 PM, Recital Hall.
  _ev(id: 'ev-dandana-25', en: 'Dandana — Musaed Al-Balushi', ar: 'دندنة — مساعد البلوشي',
      cat: 'concerts', tags: ['concerts', 'live_music', 'culture'], venue: 'jacc',
      dur: 120, days: [1], times: [1200], price: 12, minAge: 5,
      lang: 'Arabic', pop: .82, months: [11], motif: 'stage',
      imageUrl: 'https://s3.eu-central-1.amazonaws.com/dev-jaccimages/image/Poster_Image_Dandana.jpg',
      desc: 'Kuwaiti artist Musaed Al-Balushi performs a selection of favourite Khaleeji songs at the JACC Recital Hall.',
      descAr: 'الفنان الكويتي مساعد البلوشي يقدم مختارات من أجمل أغانيه الخليجية في قاعة الاستعراض.',
      demo: true),
  // Qatar Philharmonic Orchestra — Dec 19 2025 (Friday). Ticket price not confirmed → demo: true
  _ev(id: 'ev-qatar-phil-25', en: 'Qatar Philharmonic Orchestra', ar: 'أوركسترا قطر الفيلهارمونية',
      cat: 'concerts', tags: ['concerts', 'live_music'], venue: 'jacc',
      dur: 150, days: [5], times: [1200], price: 15, minAge: 6,
      lang: 'Instrumental', pop: .78, months: [12], motif: 'stage',
      imageUrl: 'https://s3.eu-central-1.amazonaws.com/dev-jaccimages/image/Poster_Image_Qatar_Philharmonic_Orchestra_EN_550.jpg',
      desc: 'A classical evening with the Qatar Philharmonic Orchestra at the JACC National Theatre.',
      descAr: 'أمسية كلاسيكية مع أوركسترا قطر الفيلهارمونية في المسرح الوطني بمركز جابر.',
      demo: true),
  // Home Alone in Concert — Dec 20 2025 (Saturday), 4:00 PM & 8:30 PM.
  // Ticket prices CONFIRMED: 15–65 KWD. Age 5+. Two showtimes. (source: tickets.jacc-kw.com)
  _ev(id: 'ev-home-alone-25', en: 'Home Alone in Concert', ar: 'وحيد في المنزل — حفل موسيقي',
      cat: 'concerts', tags: ['concerts', 'live_music', 'family', 'kids'], venue: 'jacc',
      dur: 115, days: [6], times: [960, 1230], price: 15, child: 15, minAge: 5,
      lang: 'English', pop: .90, months: [12], motif: 'film',
      imageUrl: 'https://s3.eu-central-1.amazonaws.com/dev-jaccimages/image/Poster_Image_Home_Alone_EN_544.jpg',
      desc: 'The classic Christmas film screened live with John Williams\' Academy Award–nominated score performed by the Qatar Philharmonic Orchestra. Two showtimes: 4:00 PM & 8:30 PM. Tickets from 15 KWD.',
      descAr: 'الفيلم الكلاسيكي على الشاشة الكبيرة مع موسيقى جون ويليامز حيّة على يد أوركسترا قطر الفيلهارمونية. عرضان: ٤:٠٠ م و٨:٣٠ م. التذاكر تبدأ من ١٥ د.ك.',
      demo: false),
  // --- Additional confirmed JACC events (2026/2027 season, jacc-kw.com) ---
  // The Eighties… The Knockout — Oct 12–17 2026, National Theatre, two shows daily
  _ev(id: 'ev-eighties', en: 'The Eighties… The Knockout', ar: 'الثمانينيات... الضربة القاضية',
      cat: 'theatre', tags: ['theatre', 'comedy', 'culture'], venue: 'jacc',
      dur: 120, days: [1, 2, 3, 4, 5, 6], times: [960, 1230], price: 12, minAge: 8,
      lang: 'Arabic', pop: .80, months: [10], motif: 'stage',
      imageUrl: 'https://www.jacc-kw.com/core/wp-content/uploads/2026/09/Website_Eventname_The_Eighties_EN_599.jpg',
      desc: 'An Arabic theatrical show revisiting the spirit and hits of the 1980s, with live music and comedy. Two shows nightly: 4 PM and 8:30 PM.',
      descAr: 'عرض مسرحي عربي يستعيد روح وأغاني الثمانينيات مع موسيقى حية وكوميديا. عرضان يومياً: ٤ م و٨:٣٠ م.',
      demo: true),
  // Samri and Qadri with Tareq Al-Khurayef — Oct 19 2026, Concert Hall
  _ev(id: 'ev-samri', en: 'Samri & Qadri — Tareq Al-Khurayef', ar: 'سامري وقدري — طارق الخريّف',
      cat: 'concerts', tags: ['concerts', 'live_music', 'culture'], venue: 'jacc',
      dur: 120, days: [1], times: [1200], price: 10, minAge: 5,
      lang: 'Arabic', pop: .75, months: [10], motif: 'stage',
      imageUrl: 'https://www.jacc-kw.com/core/wp-content/uploads/2026/09/Website_Eventname_Samri_Qadri_EN_600.jpg',
      desc: 'Kuwaiti artist Tareq Al-Khurayef performs traditional samri and qadri folk songs at the Sheikh Jaber Al-Ali Concert Hall.',
      descAr: 'الفنان الكويتي طارق الخريّف يقدم أغاني السامري والقدري التراثية في قاعة الشيخ جابر العلي للحفلات.',
      demo: true),
  // Sahabet Kaif — Oct 21 2026, Recital Hall
  _ev(id: 'ev-sahabet-kaif', en: 'Sahabet Kaif', ar: 'صاحبة كيف',
      cat: 'concerts', tags: ['concerts', 'live_music'], venue: 'jacc',
      dur: 120, days: [3], times: [1140], price: 10, minAge: 5,
      lang: 'Arabic', pop: .72, months: [10], motif: 'stage',
      imageUrl: 'https://www.jacc-kw.com/core/wp-content/uploads/2026/09/Website_Eventname_Sahabet_Kaif_EN_602.jpg',
      desc: 'An evening of Arabic song at the JACC Recital Hall.',
      descAr: 'أمسية غنائية عربية في قاعة الاستعراض بمركز جابر الثقافي.',
      demo: true),
  // Two Songs in One — Oct 28 2026, Concert Hall
  _ev(id: 'ev-two-songs', en: 'Two Songs in One', ar: 'أغنيتان في واحدة',
      cat: 'concerts', tags: ['concerts', 'live_music', 'culture'], venue: 'jacc',
      dur: 120, days: [3], times: [1200], price: 10, minAge: 5,
      lang: 'Arabic', pop: .74, months: [10], motif: 'stage',
      imageUrl: 'https://www.jacc-kw.com/core/wp-content/uploads/2026/09/Website_Eventname_Two_Songs_in_One_EN_603.jpg',
      desc: 'A concert celebrating classic Arabic songs, performed live at the Sheikh Jaber Al-Ali Concert Hall.',
      descAr: 'حفل يحتفي بأغاني الطرب الكلاسيكي يقام في قاعة الشيخ جابر العلي للحفلات.',
      demo: true),
  // Mai Farouk — Nov 5 2026, National Theatre
  _ev(id: 'ev-mai-farouk', en: 'Mai Farouk', ar: 'مي فاروق',
      cat: 'concerts', tags: ['concerts', 'live_music'], venue: 'jacc',
      dur: 120, days: [4], times: [1230], price: 15, minAge: 6,
      lang: 'Arabic', pop: .82, months: [11], motif: 'stage',
      imageUrl: 'https://www.jacc-kw.com/core/wp-content/uploads/2026/09/Website_Eventname_Mai_Farouk_EN_605.jpg',
      desc: 'Egyptian singer Mai Farouk performs at the JACC National Theatre.',
      descAr: 'المطربة المصرية مي فاروق تحيي حفلها في المسرح الوطني بمركز جابر الثقافي.',
      demo: true),
  // Víctor Espínola — Nov 7 2026, Amphitheatre
  _ev(id: 'ev-espinola', en: 'Víctor Espínola — Amphitheatre', ar: 'فيكتور إسبينولا — الأمفيثياتر',
      cat: 'concerts', tags: ['concerts', 'live_music'], venue: 'jacc',
      dur: 90, days: [6], times: [1200], price: 8, minAge: 5,
      lang: 'Instrumental', pop: .68, months: [11], motif: 'stage',
      imageUrl: 'https://www.jacc-kw.com/core/wp-content/uploads/2026/10/Website_Eventname_V%C3%ADctor_Esp%C3%ADnola_EN_607.jpg',
      desc: 'World-music harpist Víctor Espínola performs under the open sky at the JACC Amphitheatre.',
      descAr: 'عازف القيثارة العالمي فيكتور إسبينولا يقدم عرضه في الأمفيثياتر المفتوح بمركز جابر الثقافي.',
      demo: true),
  _ev(id: 'ev-kids-science', en: 'Kids science show', ar: 'عرض علمي للأطفال', cat: 'family', tags: ['family', 'kids'], venue: 'sci', dur: 60, days: [5, 6], times: [660], price: 3, child: 3, minAge: 4, pop: .6, motif: 'star', imageUrl: 'https://images.pexels.com/photos/8923368/pexels-photo-8923368.jpeg?auto=compress&cs=tinysrgb&w=800', desc: 'Live experiments with lots of foam.', descAr: 'تجارب حية مليئة بالرغوة.'),
  _ev(id: 'ev-stars', en: 'Desert stargazing night', ar: 'ليلة رصد النجوم في البر', cat: 'desert', tags: ['desert', 'adventure', 'photography'], venue: 'kabd', dur: 180, days: [4, 5], times: [1140], price: 30, child: 15, minAge: 6, indoor: false, acc: false, months: [11, 12, 1, 2, 3], pop: .65, motif: 'dunes', imageUrl: 'https://images.pexels.com/photos/8357639/pexels-photo-8357639.jpeg?auto=compress&cs=tinysrgb&w=800', desc: 'Telescopes and a guide away from city lights.', descAr: 'تلسكوبات ومرشد بعيداً عن أضواء المدينة.'),
];

final Map<String, Listing> catalog = {for (final l in [...places, ...events]) l.id: l};
