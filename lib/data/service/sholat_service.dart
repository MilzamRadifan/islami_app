import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:islami_app/data/model/hijri_date_model.dart';
import 'package:islami_app/data/model/location_model.dart';
import 'package:islami_app/data/model/schedule_model.dart';
import 'package:islami_app/data/model/sholat_reminder_model.dart';

class SholatService {
  static const String _baseUrl = 'https://api.myquran.com/v2';

  static const Map<String, String> _cityIdMapping = {
    'kab. lampung tengah': '1001',
    'kab. lampung utara': '1002',
    'kab. lampung selatan': '1003',
    'kab. lampung barat': '1004',
    'kab. lampung timur': '1005',
    'kab. mesuji': '1006',
    'kab. pesawaran': '1007',
    'kab. pesisir barat': '1008',
    'kab. pringsewu': '1009',
    'kab. tulang bawang': '1010',
    'kab. tulang bawang barat': '1011',
    'kab. tanggamus': '1012',
    'kab. way kanan': '1013',
    'kota bandar lampung': '1014',
    'kota metro': '1015',
    'kab. lebak': '1101',
    'kab. pandeglang': '1102',
    'kab. serang': '1103',
    'kab. tangerang': '1104',
    'kota cilegon': '1105',
    'kota serang': '1106',
    'kota tangerang': '1107',
    'kota tangerang selatan': '1108',
    'kab. bandung': '1201',
    'kab. bandung barat': '1202',
    'kab. bekasi': '1203',
    'kab. bogor': '1204',
    'kab. ciamis': '1205',
    'kab. cianjur': '1206',
    'kab. cirebon': '1207',
    'kab. garut': '1208',
    'kab. indramayu': '1209',
    'kab. karawang': '1210',
    'kab. kuningan': '1211',
    'kab. majalengka': '1212',
    'kab. pangandaran': '1213',
    'kab. purwakarta': '1214',
    'kab. subang': '1215',
    'kab. sukabumi': '1216',
    'kab. sumedang': '1217',
    'kab. tasikmalaya': '1218',
    'kota bandung': '1219',
    'kota banjar': '1220',
    'kota bekasi': '1221',
    'kota bogor': '1222',
    'kota cimahi': '1223',
    'kota cirebon': '1224',
    'kota depok': '1225',
    'kota sukabumi': '1226',
    'kota tasikmalaya': '1227',
    'kota jakarta': '1301',
    'kab. kepulauan seribu': '1302',
    'kab. banjarnegara': '1401',
    'kab. banyumas': '1402',
    'kab. batang': '1403',
    'kab. blora': '1404',
    'kab. boyolali': '1405',
    'kab. brebes': '1406',
    'kab. cilacap': '1407',
    'kab. demak': '1408',
    'kab. grobogan': '1409',
    'kab. jepara': '1410',
    'kab. karanganyar': '1411',
    'kab. kebumen': '1412',
    'kab. kendal': '1413',
    'kab. klaten': '1414',
    'kab. kudus': '1415',
    'kab. magelang': '1416',
    'kab. pati': '1417',
    'kab. pekalongan': '1418',
    'kab. pemalang': '1419',
    'kab. purbalingga': '1420',
    'kab. purworejo': '1421',
    'kab. rembang': '1422',
    'kab. semarang': '1423',
    'kab. sragen': '1424',
    'kab. sukoharjo': '1425',
    'kab. tegal': '1426',
    'kab. temanggung': '1427',
    'kab. wonogiri': '1428',
    'kab. wonosobo': '1429',
    'kota magelang': '1430',
    'kota pekalongan': '1431',
    'kota salatiga': '1432',
    'kota semarang': '1433',
    'kota surakarta': '1434',
    'kota tegal': '1435',
    'kab. bantul': '1501',
    'kab. gunungkidul': '1502',
    'kab. kulon progo': '1503',
    'kab. sleman': '1504',
    'kota yogyakarta': '1505',
    'kab. bangkalan': '1601',
    'kab. banyuwangi': '1602',
    'kab. blitar': '1603',
    'kab. bojonegoro': '1604',
    'kab. bondowoso': '1605',
    'kab. gresik': '1606',
    'kab. jember': '1607',
    'kab. jombang': '1608',
    'kab. kediri': '1609',
    'kota kediri': '1632',
    'kab. lamongan': '1610',
    'kab. lumajang': '1611',
    'kab. madiun': '1612',
    'kab. magetan': '1613',
    'kab. malang': '1614',
    'kab. mojokerto': '1615',
    'kab. nganjuk': '1616',
    'kab. ngawi': '1617',
    'kab. pacitan': '1618',
    'kab. pamekasan': '1619',
    'kab. pasuruan': '1620',
    'kab. ponorogo': '1621',
    'kab. probolinggo': '1622',
    'kab. sampang': '1623',
    'kab. sidoarjo': '1624',
    'kab. situbondo': '1625',
    'kab. sumenep': '1626',
    'kab. trenggalek': '1627',
    'kab. tuban': '1628',
    'kab. tulungagung': '1629',
    'kota batu': '1630',
    'kota blitar': '1631',
    'kota madiun': '1633',
    'kota malang': '1634',
    'kota mojokerto': '1635',
    'kota pasuruan': '1636',
    'kota probolinggo': '1637',
    'kota surabaya': '1638',
    'kab. badung': '1701',
    'kab. bangli': '1702',
    'kab. buleleng': '1703',
    'kab. gianyar': '1704',
    'kab. jembrana': '1705',
    'kab. karangasem': '1706',
    'kab. klungkung': '1707',
    'kab. tabanan': '1708',
    'kota denpasar': '1709',
    'kab. bima': '1801',
    'kab. dompu': '1802',
    'kab. lombok barat': '1803',
    'kab. lombok tengah': '1804',
    'kab. lombok timur': '1805',
    'kab. lombok utara': '1806',
    'kab. sumbawa': '1807',
    'kab. sumbawa barat': '1808',
    'kota bima': '1809',
    'kota mataram': '1810',
    'kab. alor': '1901',
    'kab. belu': '1902',
    'kab. ende': '1903',
    'kab. flores timur': '1904',
    'kab. kupang': '1905',
    'kab. lembata': '1906',
    'kab. malaka': '1907',
    'kab. manggarai': '1908',
    'kab. manggarai barat': '1909',
    'kab. manggarai timur': '1910',
    'kab. ngada': '1911',
    'kab. nagekeo': '1912',
    'kab. rote ndao': '1913',
    'kab. sabu raijua': '1914',
    'kab. sikka': '1915',
    'kab. sumba barat': '1916',
    'kab. sumba barat daya': '1917',
    'kab. sumba tengah': '1918',
    'kab. sumba timur': '1919',
    'kab. timor tengah selatan': '1920',
    'kab. timor tengah utara': '1921',
    'kota kupang': '1922',
    'kab. bengkayang': '2001',
    'kab. kapuas hulu': '2002',
    'kab. kayong utara': '2003',
    'kab. ketapang': '2004',
    'kab. kubu raya': '2005',
    'kab. landak': '2006',
    'kab. melawi': '2007',
    'kab. mempawah': '2008',
    'kab. sambas': '2009',
    'kab. sanggau': '2010',
    'kab. sekadau': '2011',
    'kab. sintang': '2012',
    'kota pontianak': '2013',
    'kota singkawang': '2014',
    'kab. balangan': '2101',
    'kab. banjar': '2102',
    'kab. barito kuala': '2103',
    'kab. hulu sungai selatan': '2104',
    'kab. hulu sungai tengah': '2105',
    'kab. hulu sungai utara': '2106',
    'kab. kotabaru': '2107',
    'kab. tabalong': '2108',
    'kab. tanah bumbu': '2109',
    'kab. tanah laut': '2110',
    'kab. tapin': '2111',
    'kota banjarbaru': '2112',
    'kota banjarmasin': '2113',
    'kab. barito selatan': '2201',
    'kab. barito timur': '2202',
    'kab. barito utara': '2203',
    'kab. gunung mas': '2204',
    'kab. kapuas': '2205',
    'kab. katingan': '2206',
    'kab. kotawaringin barat': '2207',
    'kab. kotawaringin timur': '2208',
    'kab. lamandau': '2209',
    'kab. murung raya': '2210',
    'kab. pulang pisau': '2211',
    'kab. sukamara': '2212',
    'kab. seruyan': '2213',
    'kota palangkaraya': '2214',
    'kab. berau': '2301',
    'kab. kutai barat': '2302',
    'kab. kutai kartanegara': '2303',
    'kab. kutai timur': '2304',
    'kab. mahakam ulu': '2305',
    'kab. paser': '2306',
    'kab. penajam paser utara': '2307',
    'kota balikpapan': '2308',
    'kota bontang': '2309',
    'kota samarinda': '2310',
    'kab. bulungan': '2401',
    'kab. malinau': '2402',
    'kab. nunukan': '2403',
    'kab. tana tidung': '2404',
    'kota tarakan': '2405',
    'kab. boalemo': '2501',
    'kab. bone bolango': '2502',
    'kab. gorontalo': '2503',
    'kab. gorontalo utara': '2504',
    'kab. pohuwato': '2505',
    'kota gorontalo': '2506',
    'kab. bantaeng': '2601',
    'kab. barru': '2602',
    'kab. bone': '2603',
    'kab. bulukumba': '2604',
    'kab. enrekang': '2605',
    'kab. gowa': '2606',
    'kab. jeneponto': '2607',
    'kab. kepulauan selayar': '2608',
    'kab. luwu': '2609',
    'kab. luwu timur': '2610',
    'kab. luwu utara': '2611',
    'kab. maros': '2612',
    'kab. pangkajene dan kepulauan': '2613',
    'kab. pinrang': '2614',
    'kab. sidenreng rappang': '2615',
    'kab. sinjai': '2616',
    'kab. soppeng': '2617',
    'kab. takalar': '2618',
    'kab. tana toraja': '2619',
    'kab. toraja utara': '2620',
    'kab. wajo': '2621',
    'kota makassar': '2622',
    'kota palopo': '2623',
    'kota parepare': '2624',
    'kab. bombana': '2701',
    'kab. buton': '2702',
    'kab. buton selatan': '2703',
    'kab. buton tengah': '2704',
    'kab. buton utara': '2705',
    'kab. kolaka': '2706',
    'kab. kolaka timur': '2707',
    'kab. kolaka utara': '2708',
    'kab. konawe': '2709',
    'kab. konawe kepulauan': '2710',
    'kab. konawe selatan': '2711',
    'kab. konawe utara': '2712',
    'kab. muna': '2713',
    'kab. muna barat': '2714',
    'kab. wakatobi': '2715',
    'kota bau-bau': '2716',
    'kota kendari': '2717',
    'kab. banggai': '2801',
    'kab. banggai kepulauan': '2802',
    'kab. banggai laut': '2803',
    'kab. buol': '2804',
    'kab. donggala': '2805',
    'kab. morowali': '2806',
    'kab. morowali utara': '2807',
    'kab. parigi moutong': '2808',
    'kab. poso': '2809',
    'kab. sigi': '2810',
    'kab. tojo una-una': '2811',
    'kab. toli-toli': '2812',
    'kota palu': '2813',
    'kab. bolaang mongondow': '2901',
    'kab. bolaang mongondow selatan': '2902',
    'kab. bolaang mongondow timur': '2903',
    'kab. bolaang mongondow utara': '2904',
    'kab. kepulauan sangihe': '2905',
    'kab. kepulauan siau tagulandang biaro': '2906',
    'kab. kepulauan talaud': '2907',
    'kab. minahasa': '2908',
    'kab. minahasa selatan': '2909',
    'kab. minahasa tenggara': '2910',
    'kab. minahasa utara': '2911',
    'kota bitung': '2912',
    'kota kotamobagu': '2913',
    'kota manado': '2914',
    'kota tomohon': '2915',
    'kab. majene': '3001',
    'kab. mamasa': '3002',
    'kab. mamuju': '3003',
    'kab. mamuju tengah': '3004',
    'kab. mamuju utara': '3005',
    'kab. polewali mandar': '3006',
    'kab. buru': '3101',
    'kab. buru selatan': '3102',
    'kab. kepulauan aru': '3103',
    'kab. maluku barat daya': '3104',
    'kab. maluku tengah': '3105',
    'kab. maluku tenggara': '3106',
    'kab. maluku tenggara barat': '3107',
    'kab. seram bagian barat': '3108',
    'kab. seram bagian timur': '3109',
    'kota ambon': '3110',
    'kota tual': '3111',
    'kab. halmahera barat': '3201',
    'kab. halmahera tengah': '3202',
    'kab. halmahera utara': '3203',
    'kab. halmahera selatan': '3204',
    'kab. kepulauan sula': '3205',
    'kab. halmahera timur': '3206',
    'kab. pulau morotai': '3207',
    'kab. pulau taliabu': '3208',
    'kota ternate': '3209',
    'kota tidore kepulauan': '3210',
    'kota sofifi': '3211',
    'kab. asmat': '3301',
    'kab. biak numfor': '3302',
    'kab. boven digoel': '3303',
    'kab. deiyai': '3304',
    'kab. dogiyai': '3305',
    'kab. intan jaya': '3306',
    'kab. jayapura': '3307',
    'kab. jayawijaya': '3308',
    'kab. keerom': '3309',
    'kab. kepulauan yapen': '3310',
    'kab. lanny jaya': '3311',
    'kab. mamberamo raya': '3312',
    'kab. mamberamo tengah': '3313',
    'kab. mappi': '3314',
    'kab. merauke': '3315',
    'kab. mimika': '3316',
    'kab. nabire': '3317',
    'kab. nduga': '3318',
    'kab. paniai': '3319',
    'kab. pegunungan bintang': '3320',
    'kab. puncak': '3321',
    'kab. puncak jaya': '3322',
    'kab. sarmi': '3323',
    'kab. supiori': '3324',
    'kab. tolikara': '3325',
    'kab. waropen': '3326',
    'kab. yahukimo': '3327',
    'kab. yalimo': '3328',
    'kota jayapura': '3329',
    'kab. yapen waropen': '3330',
    'kab. fakfak': '3401',
    'kab. kaimana': '3402',
    'kab. manokwari': '3403',
    'kab. manokwari selatan': '3404',
    'kab. maybrat': '3405',
    'kab. pegunungan arfak': '3406',
    'kab. raja ampat': '3407',
    'kab. sorong': '3408',
    'kab. sorong selatan': '3409',
    'kab. tambrauw': '3410',
    'kab. teluk bintuni': '3411',
    'kab. teluk wondama': '3412',
    'kota sorong': '3413',
    'kab. aceh barat': '0101',
    'kab. aceh barat daya': '0102',
    'kab. aceh besar': '0103',
    'kab. aceh jaya': '0104',
    'kab. aceh selatan': '0105',
    'kab. aceh singkil': '0106',
    'kab. aceh tamiang': '0107',
    'kab. aceh tengah': '0108',
    'kab. aceh tenggara': '0109',
    'kab. aceh timur': '0110',
    'kab. aceh utara': '0111',
    'kab. bener meriah': '0112',
    'kab. bireuen': '0113',
    'kab. gayo lues': '0114',
    'kab. nagan raya': '0115',
    'kab. pidie': '0116',
    'kab. pidie jaya': '0117',
    'kab. simeulue': '0118',
    'kota banda aceh': '0119',
    'kota langsa': '0120',
    'kota lhokseumawe': '0121',
    'kota sabang': '0122',
    'kota subulussalam': '0123',
    'kab. asahan': '0201',
    'kab. batubara': '0202',
    'kab. dairi': '0203',
    'kab. deli serdang': '0204',
    'kab. humbang hasundutan': '0205',
    'kab. karo': '0206',
    'kab. labuhanbatu': '0207',
    'kab. labuhanbatu selatan': '0208',
    'kab. labuhanbatu utara': '0209',
    'kab. langkat': '0210',
    'kab. mandailing natal': '0211',
    'kab. nias': '0212',
    'kab. nias barat': '0213',
    'kab. nias selatan': '0214',
    'kab. nias utara': '0215',
    'kab. padang lawas': '0216',
    'kab. padang lawas utara': '0217',
    'kab. pakpak bharat': '0218',
    'kab. samosir': '0219',
    'kab. serdang bedagai': '0220',
    'kab. simalungun': '0221',
    'kab. tapanuli selatan': '0222',
    'kab. tapanuli tengah': '0223',
    'kab. tapanuli utara': '0224',
    'kab. toba samosir': '0225',
    'kota binjai': '0226',
    'kota gunungsitoli': '0227',
    'kota medan': '0228',
    'kota padangsidempuan': '0229',
    'kota pematangsiantar': '0230',
    'kota sibolga': '0231',
    'kota tanjungbalai': '0232',
    'kota tebing tinggi': '0233',
    'kab. agam': '0301',
    'kab. dharmasraya': '0302',
    'kab. kepulauan mentawai': '0303',
    'kab. lima puluh kota': '0304',
    'kab. padang pariaman': '0305',
    'kab. pasaman': '0306',
    'kab. pasaman barat': '0307',
    'kab. pesisir selatan': '0308',
    'kab. sijunjung': '0309',
    'kab. solok': '0310',
    'kab. solok selatan': '0311',
    'kab. tanah datar': '0312',
    'kota bukittinggi': '0313',
    'kota padang': '0314',
    'kota padangpanjang': '0315',
    'kota pariaman': '0316',
    'kota payakumbuh': '0317',
    'kota sawahlunto': '0318',
    'kota solok': '0319',
    'kab. bengkalis': '0401',
    'kab. indragiri hilir': '0402',
    'kab. indragiri hulu': '0403',
    'kab. kampar': '0404',
    'kab. kepulauan meranti': '0405',
    'kab. kuantan singingi': '0406',
    'kab. pelalawan': '0407',
    'kab. rokan hilir': '0408',
    'kab. rokan hulu': '0409',
    'kab. siak': '0410',
    'kota dumai': '0411',
    'kota pekanbaru': '0412',
    'kab. bintan': '0501',
    'kab. karimun': '0502',
    'kab. kepulauan anambas': '0503',
    'kab. lingga': '0504',
    'kab. natuna': '0505',
    'kota batam': '0506',
    'kota tanjung pinang': '0507',
    'pulau tambelan kab. bintan': '0508',
    'pekajang kab. lingga': '0509',
    'pulau serasan kab. natuna': '0510',
    'pulau midai kab. natuna': '0511',
    'pulau laut kab. natuna': '0512',
    'kab. batanghari': '0601',
    'kab. bungo': '0602',
    'kab. kerinci': '0603',
    'kab. merangin': '0604',
    'kab. muaro jambi': '0605',
    'kab. sarolangun': '0606',
    'kab. tanjung jabung barat': '0607',
    'kab. tanjung jabung timur': '0608',
    'kab. tebo': '0609',
    'kota jambi': '0610',
    'kota sungai penuh': '0611',
    'kab. bengkulu selatan': '0701',
    'kab. bengkulu tengah': '0702',
    'kab. bengkulu utara': '0703',
    'kab. kaur': '0704',
    'kab. kepahiang': '0705',
    'kab. lebong': '0706',
    'kab. mukomuko': '0707',
    'kab. rejang lebong': '0708',
    'kab. seluma': '0709',
    'kota bengkulu': '0710',
    'kab. banyuasin': '0801',
    'kab. empat lawang': '0802',
    'kab. lahat': '0803',
    'kab. muara enim': '0804',
    'kab. musi banyuasin': '0805',
    'kab. musi rawas': '0806',
    'kab. musi rawas utara': '0807',
    'kab. ogan ilir': '0808',
    'kab. ogan komering ilir': '0809',
    'kab. ogan komering ulu': '0810',
    'kab. ogan komering ulu selatan': '0811',
    'kab. ogan komering ulu timur': '0812',
    'kab. penukal abab lematang ilir': '0813',
    'kota lubuklinggau': '0814',
    'kota pagar alam': '0815',
    'kota palembang': '0816',
    'kota prabumulih': '0817',
    'kab. bangka': '0901',
    'kab. bangka barat': '0902',
    'kab. bangka selatan': '0903',
    'kab. bangka tengah': '0904',
    'kab. belitung': '0905',
    'kab. belitung timur': '0906',
    'kota pangkal pinang': '0907',
  };

  //* normalisasi nama kota dari data mentah geolocator
  String _normalizeCityName(String rawCityName) {
    final rawWords = rawCityName.toLowerCase().trim().split(RegExp(r'\s+'));

    String? bestMatch;
    int maxWordMatches = 0;

    for (final key in _cityIdMapping.keys) {
      final keyWords = key.toLowerCase().split(RegExp(r'\s+'));
      
      final wordMatches =
          rawWords.where((word) => keyWords.contains(word)).length;
      
      if (wordMatches > maxWordMatches) {
        maxWordMatches = wordMatches;
        bestMatch = key;
      } else if (wordMatches == maxWordMatches && bestMatch != null) {
        
        if (key.startsWith('kota ') && bestMatch.startsWith('kab. ')) {
          bestMatch = key;
        }
      }
    }

    return bestMatch ?? 'Kota Tidak Diketahui';
  }

  //* dapatkan id kota dari nama kota yang dinormalisasi
  String? _getCityIdFromNormalizedName(String normalizedCityName) {
    return _cityIdMapping[normalizedCityName];
  }

  //* dapatkan koordinat pengguna saat ini
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak aktif');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak secara permanen');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  //* dapatkan alamat pengguna (nama kota) berdasarkan koordinat
  Future<Map<String, String>> getCityNameAndIdFromCoordinates(
      double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final rawCityName = placemark.subAdministrativeArea ??
            placemark.locality ??
            'Kota Tidak Diketahui';
        final normalizedCityName = _normalizeCityName(rawCityName);
        final cityId = _getCityIdFromNormalizedName(normalizedCityName);
        if (cityId == null) {
          throw Exception('ID kota tidak ditemukan untuk: $normalizedCityName');
        }
        return {
          'cityName': normalizedCityName
              .replaceAll('kota ', '')
              .replaceAll('kab. ', ''),
          'cityId': cityId,
        };
      } else {
        throw Exception('Tidak dapat menemukan nama kota');
      }
    } catch (e) {
      throw Exception('Gagal mendapatkan nama kota: $e');
    }
  }

  //* dapatkan id lokasi
  Future<CitySearchResponse> getCityId(String cityName) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/sholat/kota/cari/$cityName'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CitySearchResponse.fromJson(data);
      } else {
        throw Exception(
            'Gagal mendapatkan data kota: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mendapatkan ID kota: $e');
    }
  }

  //* dapatkan waktu sholat berdasarkan lokasi pengguna
  Future<PrayerScheduleResponse> getPrayerSchedule(
      String cityId, String date) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/sholat/jadwal/$cityId/$date'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PrayerScheduleResponse.fromJson(data);
      } else {
        throw Exception(
            'Gagal mendapatkan jadwal sholat: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mendapatkan jadwal sholat: $e');
    }
  }

  //* dapatkan tanggal hijriah untuk saat ini
  Future<HijriDateResponse> getHijriDate(String date) async {
    try {
      print('Mengambil tanggal Hijriah untuk tanggal: $date');
      final response =
          await http.get(Uri.parse('$_baseUrl/cal/hijr/$date?adj=-1'));
      print('Respons status code: ${response.statusCode}');
      print('Respons body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == true) {
          return HijriDateResponse.fromJson(data);
        } else {
          throw Exception(
              'Gagal mendapatkan tanggal Hijriah: Status false dari API');
        }
      } else {
        throw Exception(
            'Gagal mendapatkan tanggal Hijriah: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat mengambil tanggal Hijriah: $e');
      throw Exception('Gagal mendapatkan tanggal Hijriah: $e');
    }
  }
  
  //* simpan atau perbarui pengingat sholat
  Future<void> saveOrUpdateReminder(SholatReminderModel reminder) async {
    final box = Hive.box<SholatReminderModel>('sholat_reminders');
    await box.put(reminder.cityName, reminder);
  }

  //* dapatkan pengingat sholat untuk lokasi tertentu
  Future<Map<String, bool>> getRemindersForLocation(String cityName) async {
    final box = Hive.box<SholatReminderModel>('sholat_reminders');
    final reminder = box.get(cityName);

    if (reminder != null) {
      return reminder.prayerReminders;
    } else {
      return {};
    }
  }
}
