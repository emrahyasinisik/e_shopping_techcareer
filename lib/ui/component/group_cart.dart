import 'package:e_shopping_techcareer/data/entity/sepette.dart';

class GroupCart {
  static Map<String, List<Sepette>> groupCartItems(List<Sepette> items) {
    //buraya bak map ne idi tablo mu yoksa liste mi
    //Sepette'leri adlarına göre gruplayan fonksiyon
    Map<String, List<Sepette>> groupedItems = {};
    for (var item in items) {
      if (!groupedItems.containsKey(item.ad)) {
        groupedItems[item.ad] = [];
      }
      groupedItems[item.ad]!.add(item);
    }
    return groupedItems;
  }
}
