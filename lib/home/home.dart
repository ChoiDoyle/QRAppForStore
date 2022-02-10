import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:qrproject/authenticate/sign_in.dart';
import 'package:qrproject/home/custom_func.dart';
import 'data.dart';

class Home extends StatefulWidget {
  String storeID = '';
  Home({Key? key, required this.storeID}) : super(key: key);

  @override
  _HomeState createState() => _HomeState(storeID);
}

class _HomeState extends State<Home> {
  late Future<List<PaymentData>> _paymentDataForUpdate;

  String storeID = '';
  _HomeState(this.storeID);

  List<OrderData> dataListFinal = [];

  int navigationIndex = 0;

  Map<String, int> priceList = <String, int>{};

  TextEditingController logoutPWController = TextEditingController();

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
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('$storeID의 오늘 하루도 화이팅!',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.grey[200],
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.black,
              ),
              onPressed: () {
                showLogoutDialogFunc(context);
              },
            ),
          ],
        ),
        body: buildListView(),
        bottomNavigationBar: buildNavigationBar(),
      ),
    );
  }

  showLogoutDialogFunc(context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey,
                      ),
                      padding: EdgeInsets.all(10.h),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 600.h,
                      child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 20.h,
                              ),
                              Text(
                                '아래에 비밀번호를 입력해주세요',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 50.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Container(
                                  padding: EdgeInsets.all(5.h),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white)),
                                  child: TextField(
                                    controller: logoutPWController,
                                  )),
                              Text(
                                '현재 프로토단계로 사장님의 가게상황외에는 접근하실 수 없습니다.\n로그아웃이 필요하시면 아래의 번호로 연락주세요!\n010-4315-5840',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (logoutPWController.text == '0509') {
                                    CustomFunc().removeSharedVar('storeName');
                                    FirebaseAuth.instance.signOut().then((_) =>
                                        {
                                          CustomFunc()
                                              .startPage(context, SignIn())
                                        });
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text('확인'),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                    alignment: Alignment.center,
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 70.sp,
                                      fontWeight: FontWeight.bold,
                                    )),
                              )
                            ]),
                      ))));
        });
  }

  buildListView() {
    return navigationIndex == 0 ? orderStream() : paymentBuilder();
  }

  BottomNavigationBar buildNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.shifting,
      currentIndex: navigationIndex,
      onTap: (index) => setState(() => navigationIndex = index),
      fixedColor: Colors.black,
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.food_bank,
              color: Colors.black,
            ),
            label: '주문',
            backgroundColor: Colors.grey[200]),
        BottomNavigationBarItem(
            icon: Icon(Icons.attach_money, color: Colors.black),
            label: '결제',
            backgroundColor: Colors.grey[200]),
      ],
    );
  }

//Order List
  StreamBuilder<Event> orderStream() {
    return StreamBuilder(
        stream: FirebaseDatabase.instance
            .reference()
            .child('Order/$storeID')
            .orderByKey()
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
                OrderData data = OrderData(
                    dataMap[key]['menu'], phone, table, timestamp, key);
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
              ));
        });
  }

  Widget orderCardUI(Map menu, String phone, String table, String timestamp) {
    final date = timestamp.split('-')[0];
    final time = timestamp.split('-')[1];
    return Container(
      margin: EdgeInsets.only(bottom: 0, top: 20.h),
      padding: EdgeInsets.only(left: 40.h, right: 40.h, bottom: 20.h),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.only(
                bottomLeft:
                    Radius.circular(MediaQuery.of(context).size.height * 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(-10.0, 0.0),
                  blurRadius: 20.0.r,
                  spreadRadius: 4.0.r,
                )
              ]),
          padding: EdgeInsets.only(
            left: 60.h,
            top: 20.h,
            bottom: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(right: 40.h),
                  child: Text(
                    '$table번 테이블 주문내역',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 70.sp,
                        fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: 20.h,
              ),
              Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(right: 40.h),
                  child: Text(
                    '주문시각 : ${date.substring(2, 4)}월 ${date.substring(4, 6)}일 ${time.substring(0, 2)}시 ${time.substring(3, 5)}분',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 45.sp,
                        fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: 20.h,
              ),
              orderMenuList(menu, context),
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
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 80.h,
                  width: 650.h,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      menuName,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 80.h,
                  width: 100.h,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ' : ',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 80.h,
                  width: 200.h,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$menuNo개',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
          ],
        ));
  }

  showOrderDialogFunc(context, dbKey, phone, table, menu, timestamp) {
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey,
                      ),
                      padding: EdgeInsets.all(10.h),
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 350.h,
                      child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 30.h,
                              ),
                              Text(
                                '주문이 나갔습니까?',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 80.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await FirebaseDatabase.instance
                                      .reference()
                                      .child('Order/$storeID/$dbKey')
                                      .remove();
                                  await FirebaseDatabase.instance
                                      .reference()
                                      .child('Payment/$storeID/${phone}_$table')
                                      .push()
                                      .set(menu);
                                  Navigator.pop(context);
                                },
                                child: const Text('확인'),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                    alignment: Alignment.center,
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 70.sp,
                                      fontWeight: FontWeight.bold,
                                    )),
                              )
                            ]),
                      ))));
        });
  }

//Payment List
  Widget paymentBuilder() {
    setState(() {
      _paymentDataForUpdate = fetchPaymentData();
    });
    return FutureBuilder<List<PaymentData>>(
      future: _paymentDataForUpdate,
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
      margin: EdgeInsets.only(bottom: 0, top: 20.h),
      padding: EdgeInsets.only(left: 40.h, right: 40.h, bottom: 20.h),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.only(
                bottomLeft:
                    Radius.circular(MediaQuery.of(context).size.height * 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(-10.0, 0.0),
                  blurRadius: 20.0.r,
                  spreadRadius: 4.0.r,
                )
              ]),
          padding: EdgeInsets.only(
            left: 60.h,
            top: 20.h,
            bottom: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(right: 40.h),
                child: Text(
                  '$table번 테이블 합계',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 80.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 0.2.h,
              ),
              paymentMenuList(menu, context),
              SizedBox(
                height: 0.15.h,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(right: 20.h),
                child: Text(
                  '합계 : $finalPrice원',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 60.sp,
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
              Row(
                children: [
                  Container(
                    height: 80.h,
                    width: 500.h,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        menuName,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 80.h,
                    width: 150.h,
                    child: FittedBox(
                      child: Text(
                        '($menuNo개)',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 80.h,
                    width: 80.h,
                    child: FittedBox(
                      child: Text(
                        ' : ',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 80.h,
                    width: 200.h,
                    child: FittedBox(
                      child: Text(
                        '$menuPrice원',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 0.1,
              ),
            ],
          )),
    );
  }

  showPaymentDialogFunc(context, dbKey, Map<String, int> menu) {
    int finalPrice = 0;
    menu.forEach((key, value) {
      finalPrice = finalPrice + (int.parse(priceList[key].toString()) * value);
    });
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey,
                      ),
                      padding: EdgeInsets.all(10.h),
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 400.h,
                      child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 30.h,
                              ),
                              Text(
                                '총 금액 : $finalPrice원',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 60.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '결제를 하셨습니까?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 80.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final appTimestamp =
                                      CustomFunc().getTimestamp();
                                  await FirebaseDatabase.instance
                                      .reference()
                                      .child('Payment/$storeID/$dbKey')
                                      .remove();
                                  await FirebaseFirestore.instance
                                      .collection('orderHistory_$storeID')
                                      .doc('${appTimestamp}_$dbKey')
                                      .set({'menu': menu, 'total': finalPrice});
                                  setState(() {
                                    _paymentDataForUpdate = fetchPaymentData();
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text('확인'),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                    alignment: Alignment.center,
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 70.sp,
                                      fontWeight: FontWeight.bold,
                                    )),
                              )
                            ]),
                      ))));
        });
  }
}
