class OrderData {
  String phone, table, timestamp, delivered, dbKey;
  Map menu;

  OrderData(this.menu, this.phone, this.table, this.timestamp, this.delivered,
      this.dbKey);
}

class PaymentData {
  String phone, table;
  Map<String, int> menu;

  PaymentData(this.menu, this.phone, this.table);
}

class Menu {
  String menuName, menuNo;
  Menu(this.menuName, this.menuNo);
}

class PriceList {
  final Map<String, int> priceStoreA = {
    '자작냉우동': 11000,
    '비빔냉우동': 11000,
    '어묵 또는 계란 추가': 2000,
    '수우동(기본)': 8000,
    '유부우동': 9000,
    '둥글넙적어묵우동': 9000,
    '핑거돈가스정식': 15000,
    '고로케(2조각)': 5000,
    '돈가스단품(4조각)': 8000,
    '라면 정식': 5000,
    '제주맥주': 9000,
    '카스': 4000,
    '콜라': 2000,
    '피크닉(사과)': 1000
  };
}
