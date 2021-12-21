class Data {
  String phone, table, timestamp, delivered, dbKey, paid;
  Map menu;

  Data(this.menu, this.phone, this.table, this.timestamp, this.delivered,
      this.paid, this.dbKey);
}

class Menu {
  String menuName, menuNo;
  Menu(this.menuName, this.menuNo);
}
