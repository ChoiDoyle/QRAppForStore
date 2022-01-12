import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:qrproject/home/custom_func.dart';

import 'data.dart';

class Home extends StatefulWidget {
  //storeID 중복.. 이거 지워보고 에러 있는지 확인
  String storeID = '1';
  Home({Key? key, required this.storeID}) : super(key: key);

  @override
  _HomeState createState() => _HomeState(storeID);
}

class _HomeState extends State<Home> {
  String storeID = 'i';
  _HomeState(this.storeID);

  List<OrderData> dataListFinal = [];

  int navigationIndex = 0;

  Map<String, int> priceList = <String, int>{};

  @override
  void initState() {
    super.initState();
    priceList = getPriceList(storeID);
  }

  Map<String, int> getPriceList(String storeID) {
    switch (storeID) {
      case 'StoreA':
        return PriceList().priceStoreA;
      default:
        return <String, int>{};
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return ColorfulSafeArea(
      color: Colors.cyan,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            buildTopLabel(height, width),
            SizedBox(
              height: width * 0.01,
            ),
            Expanded(child: buildListView()),
          ],
        ),
        bottomNavigationBar: buildNavigationBar(),
      ),
    );
  }

  Container buildTopLabel(double height, double width) {
    return Container(
      height: 300.h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(height * 0.1),
          ),
          color: Colors.cyan),
      child: Stack(
        children: [
          Positioned(
              top: 30.h,
              left: 0,
              child: Container(
                height: 200.h,
                width: width * 0.8,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(height * 0.03),
                      bottomRight: Radius.circular(height * 0.03),
                    )),
              )),
          Positioned(
              top: 100.h,
              left: width * 0.1,
              child: Text(storeID,
                  style: TextStyle(
                      fontSize: 80.sp,
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  buildListView() {
    return navigationIndex == 0 ? orderStream() : paymentBuilder();
  }

  BottomNavigationBar buildNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.shifting,
      currentIndex: navigationIndex,
      onTap: (index) => setState(() => navigationIndex = index),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Order',
            backgroundColor: Colors.cyan),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Payment',
            backgroundColor: Colors.cyan),
      ],
    );
  }

//Order List
  StreamBuilder<Event> orderStream() {
    return StreamBuilder(
        stream: FirebaseDatabase.instance
            .reference()
            .child('Order/$storeID')
            .orderByChild('delivered')
            .onValue,
        builder: (context, snapshot) {
          final List<OrderData> dataListUpdated = [];
          if (snapshot.hasData) {
            AudioCache().play('audio.mp3');
            final dataMap =
                Map<String, dynamic>.from((snapshot.data!).snapshot.value);
            dataMap.forEach((key, value) {
              if (dataMap[key]['ex'] != 970509) {
                String timestamp = key.toString().split('_')[0];
                String phone = key.toString().split('_')[1];
                String table = key.toString().split('_')[2];
                OrderData data = OrderData(dataMap[key]['menu'], phone, table,
                    timestamp, dataMap[key]['delivered'].toString(), key);
                dataListUpdated.add(data);
              }
            });
          }
          return orderList(dataListUpdated, context);
        });
  }

  ListView orderList(List<OrderData> dataListUpdated, BuildContext context) {
    return ListView.builder(
        //physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: dataListUpdated.length,
        itemBuilder: (_, index) {
          return GestureDetector(
              onTap: () {
                showOrderDialogFunc(
                    context,
                    dataListUpdated[index].delivered,
                    dataListUpdated[index].dbKey,
                    dataListUpdated[index].phone,
                    dataListUpdated[index].table,
                    dataListUpdated[index].menu,
                    dataListUpdated[index].timestamp);
              },
              child: orderCardUI(
                dataListUpdated[index].menu,
                dataListUpdated[index].phone,
                dataListUpdated[index].table,
                dataListUpdated[index].timestamp,
                dataListUpdated[index].delivered,
              ));
        });
  }

  Widget orderCardUI(Map menu, String phone, String table, String timestamp,
      String delivered) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0, top: 10),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: Container(
          decoration: BoxDecoration(
              color: delivered == '0' ? Colors.cyan : Colors.cyan.shade100,
              borderRadius: BorderRadius.only(
                bottomLeft:
                    Radius.circular(MediaQuery.of(context).size.height * 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.15),
                  offset: const Offset(-10.0, 0.0),
                  blurRadius: 20.0,
                  spreadRadius: 4.0,
                )
              ]),
          padding: const EdgeInsets.only(
            left: 30,
            top: 10,
            bottom: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    '$table번 테이블',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 90.sp,
                        fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: 0.02.h,
              ),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    '주문시각 : $timestamp',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: 0.05.h,
              ),
              orderMenuList(menu, context),
              SizedBox(
                height: 0.1.h,
              ),
            ],
          )),
    );
  }

  ListView orderMenuList(Map menu, BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: menu.keys.length,
        itemBuilder: (_, index) {
          final List<Menu> menuListUpdated = [];
          menu.forEach((key, value) {
            Menu menu = Menu(key, value.toString());
            menuListUpdated.add(menu);
          });
          return orderMenuCardUI(
              menuListUpdated[index].menuName, menuListUpdated[index].menuNo);
        });
  }

  Widget orderMenuCardUI(String menuName, String menuNo) {
    return Container(
      padding: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
      child: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$menuName : $menuNo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 70.sp,
                ),
              ),
              const SizedBox(
                height: 0.1,
              ),
            ],
          )),
    );
  }

  showOrderDialogFunc(
      context, delivered, dbKey, phone, table, menu, timestamp) {
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.cyan,
                      ),
                      padding: EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              delivered == '0'
                                  ? '주문이 나갔습니까?'
                                  : '주문이 이미 나간 건입니다.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.05,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 0.1,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (delivered == '0') {
                                  await FirebaseDatabase.instance
                                      .reference()
                                      .child('Order/$storeID/$dbKey')
                                      .update({'delivered': 1});
                                  await FirebaseDatabase.instance
                                      .reference()
                                      .child('Payment/$storeID/${phone}_$table')
                                      .push()
                                      .set(menu);
                                }
                                Navigator.pop(context);
                              },
                              child: const Text('확인'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.black,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  )),
                            )
                          ]))));
        });
  }

//Payment List
  Widget paymentBuilder() {
    return FutureBuilder<List<PaymentData>>(
      future: fetchPaymentData(),
      builder: (context, paymentSnap) {
        switch (paymentSnap.connectionState) {
          case ConnectionState.waiting:
            return Center(child: Text('loading...'));
          default:
            if (paymentSnap.hasError) {
              return Text('에러발생');
            } else {
              return paymentList(paymentSnap.data!);
            }
        }
      },
    );
  }

  Future<List<PaymentData>> fetchPaymentData() async {
    List<PaymentData> paymentListUpdated = [];
    await FirebaseDatabase.instance
        .reference()
        .child('Payment/$storeID')
        .orderByKey()
        .get()
        .then((snapshot) {
      final paymentDataMap = Map<String, dynamic>.from(snapshot.value);
      paymentDataMap.forEach((key, value) {
        if (paymentDataMap[key]['ex'] != 970509) {
          final nextMenu =
              Map<String, dynamic>.from(Map<String, dynamic>.from(value));
          final a = nextMenu.values.toString();
          String phone = key.toString().split('_')[0];
          String table = key.toString().split('_')[1];
          PaymentData data = PaymentData(makeMap(a), phone, table);
          paymentListUpdated.add(data);
        }
      });
    });
    return paymentListUpdated;
  }

  Map<String, int> makeMap(String rawData) {
    String menu = rawData.substring(1, rawData.length - 1);
    final menu2 = menu.replaceAll('{', '').replaceAll('}', '');
    final menu3 = menu2.split(', ');
    Map<String, int> menu4 = <String, int>{};
    for (var element in menu3) {
      String key = element.split(': ')[0];
      int value = int.parse(element.split(': ')[1]);
      if (menu4.containsKey(key)) {
        menu4[key] = int.parse(menu4[key].toString()) + value.toInt();
      } else {
        menu4[key] = value.toInt();
      }
    }
    return menu4;
  }

  Widget paymentList(List<PaymentData> paymentListUpdated) => ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: paymentListUpdated.length,
      itemBuilder: (_, index) {
        return GestureDetector(
            onTap: () {
              showPaymentDialogFunc(
                  context,
                  '${paymentListUpdated[index].phone}_${paymentListUpdated[index].table}',
                  paymentListUpdated[index].menu);
            },
            child: paymentCardUI(
              paymentListUpdated[index].menu,
              paymentListUpdated[index].phone,
              paymentListUpdated[index].table,
            ));
      });

  Widget paymentCardUI(Map<String, int> menu, String phone, String table) {
    int finalPrice = 0;
    menu.forEach((key, value) {
      finalPrice = finalPrice + (int.parse(priceList[key].toString()) * value);
    });
    return Container(
      margin: const EdgeInsets.only(bottom: 0, top: 10),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.cyan,
              borderRadius: BorderRadius.only(
                bottomLeft:
                    Radius.circular(MediaQuery.of(context).size.height * 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.15),
                  offset: const Offset(-10.0, 0.0),
                  blurRadius: 20.0,
                  spreadRadius: 4.0,
                )
              ]),
          padding: const EdgeInsets.only(
            left: 30,
            top: 10,
            bottom: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  '$table번 테이블 합계',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 80.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 0.05.h,
              ),
              paymentMenuList(menu, context),
              SizedBox(
                height: 0.1.h,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  '합계 : $finalPrice원',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 80.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )),
    );
  }

  ListView paymentMenuList(Map menu, BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: menu.keys.length,
        itemBuilder: (_, index) {
          final List<Menu> menuListUpdated = [];
          menu.forEach((key, value) {
            Menu menu = Menu(key, value.toString());
            menuListUpdated.add(menu);
          });
          return paymentMenuCardUI(
              menuListUpdated[index].menuName, menuListUpdated[index].menuNo);
        });
  }

  Widget paymentMenuCardUI(String menuName, String menuNo) {
    final int menuPrice =
        int.parse(menuNo) * int.parse(priceList[menuName].toString());
    return Container(
      padding: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
      child: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$menuName($menuNo개) : $menuPrice원',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 70.sp,
                ),
              ),
              const SizedBox(
                height: 0.1,
              ),
            ],
          )),
    );
  }

  showPaymentDialogFunc(context, dbKey, menu) {
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.cyan,
                      ),
                      padding: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '결제를 하셨습니까?',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.05,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 0.1.h,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final appTimestamp =
                                    CustomFunc().getTimestamp();
                                //db 지우기
                                await FirebaseFirestore.instance
                                    .collection('orderHistory_$storeID')
                                    .doc('${appTimestamp}_$dbKey')
                                    .set({'menu': menu});
                                Navigator.pop(context);
                              },
                              child: const Text('확인'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.black,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  )),
                            )
                          ]))));
        });
  }
}
