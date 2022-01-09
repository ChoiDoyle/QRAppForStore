class OrderData {
  String phone, table, timestamp, delivered, dbKey;
  Map menu;

  OrderData(this.menu, this.phone, this.table, this.timestamp, this.delivered,
      this.dbKey);
}

class PaymentData {
  String phone, table;
  Map menu;

  PaymentData(this.menu, this.phone, this.table);
}

class Menu {
  String menuName, menuNo;
  Menu(this.menuName, this.menuNo);
}
