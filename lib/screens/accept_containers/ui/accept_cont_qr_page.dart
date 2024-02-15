import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacy_arrival/data/model/product_dto.dart';
import 'package:pharmacy_arrival/screens/accept_containers/bloc/accept_cont_launch_cubit/accept_cont_launch_cubit.dart';
import 'package:pharmacy_arrival/screens/accept_containers/bloc/accept_cont_qr_cubit/accept_cont_qr_cubit.dart';
import 'package:pharmacy_arrival/screens/accept_containers/ui/pdf_viewer_page.dart';
import 'package:pharmacy_arrival/widgets/app_loader_overlay.dart';
import 'package:pharmacy_arrival/widgets/barcode_scanner_widget.dart';
import 'package:pharmacy_arrival/widgets/custom_app_bar.dart';
import 'package:pharmacy_arrival/widgets/snackbar/custom_snackbars.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../data/model/user.dart';

class AcceptContQrPage extends StatefulWidget {
  const AcceptContQrPage({super.key});

  @override
  State<AcceptContQrPage> createState() => _AcceptContQrPageState();
}

class _AcceptContQrPageState extends State<AcceptContQrPage> {
  List<Map<String, dynamic>> jsonList = [];
  bool isDateFetched = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDate();
  }

  @override
  Widget build(BuildContext context) {
    return AppLoaderOverlay(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Сканируйте qr'.toUpperCase(),
        ),
        body: BlocConsumer<AcceptContQrCubit, AcceptContQrState>(
          listener: (context, state) {
            state.when(
              initialState: () {
                context.loaderOverlay.hide();
              },
              loadingState: () {
                context.loaderOverlay.show();
              },
              loadedState: (List<ProductDTO> products) {
                context.loaderOverlay.hide();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green,
                    content: Text("Контейнер успешно отправлен на сервер", style: TextStyle(color: Colors.white),),
                    duration: Duration(seconds: 2), // Установите желаемую длительность отображения сообщения
                  ),
                );
                BlocProvider.of<AcceptContLaunchCubit>(context).chageToActiveState();
              },
              errorState: (String message) {
                buildErrorCustomSnackBar(context, message);
                context.loaderOverlay.hide();
                Navigator.pop(context);
              },
            );
          },
          builder: (context, state) {
            return BarcodeScannerWidget(
              topPos: MediaQuery.of(context).size.height / 5,
              callback: (qr) {
                BlocProvider.of<AcceptContQrCubit>(context)
                    .getContainerByAng(number: qr);
                log(qr);
              },
              title: 'Отсканируйте контейнер',
              height: MediaQuery.of(context).size.width - 40,
              width: MediaQuery.of(context).size.width - 40,
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showBottomSheet();
          },
          child: Icon(Icons.list),
        ),
      ),
    );
  }
  void showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void getDate() async {
    if (!isDateFetched) {
      try {
        final acceptContQrCubit = BlocProvider.of<AcceptContQrCubit>(context);
        final authLocalDS = await acceptContQrCubit.getAuthLocalDS();
        final User user = await authLocalDS.getUserFromCache();
        var response = await Dio().get(
            'http://185.129.50.172/api/v2/order/list/container',
            queryParameters: {"pharm_warehouse_id": user.warehouseId});

        if (response.statusCode == 200) {
          var orders = response.data['data'] as List<dynamic>;

          if (orders != null) {
            setState(() {
              jsonList = orders
                  .where((order) => order['items'] != null)
                  .toList()
                  .cast<Map<String, dynamic>>();
            });
          } else {
            print("Orders is null");
          }
        } else {
          print("Failed to fetch data. Status code: ${response.statusCode}");
        }
        isDateFetched = true;
      } catch (e) {
        print("Error fetching data: $e");
      }
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        bool allContainersAccepted = true;
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Информация о заказе',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      SizedBox(height: 16.0),
                  itemCount: jsonList?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    final int? driverId = jsonList[index]['driver_id'] as int?;
                    final int? orderNumber =
                    jsonList[index]['order_id'] as int?;
                    final int? pointId = jsonList[index]['point_id'] as int?;
                    final List<dynamic>? items =
                    jsonList[index]['items'] as List<dynamic>?;
                    bool containersAccepted =
                    true; // Предполагаем, что все контейнеры для данного pointId приняты
                    bool allContainersAccepted =
                    true; // Предполагаем, что все контейнеры для данного pointId приняты
                    for (var item in items ?? []) {
                      final int? status = item['status'] as int?;
                      if (status != 2) {
                        // Если хотя бы один контейнер не принят, устанавливаем флаг в false
                        allContainersAccepted = false;
                        break; // Прерываем цикл, так как уже понятно, что не все контейнеры для данного pointId приняты
                      }
                    }
                    return Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Номер заказа: ${orderNumber ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Номер маршрута: ${pointId ?? 'Unknown'}',
                              style: TextStyle(fontSize: 14.0),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Контейнеры',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: items?.map((item) {
                                final String? code =
                                item['code'] as String?;
                                final int? status = item['status'] as int?;
                                return ListTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        '${code ?? 'Unknown'}',
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                      SizedBox(width: 8),
                                      if (status == 2)
                                        Icon(Icons.check_circle,
                                            color: Colors.green)
                                      else if (status == 1)
                                        Icon(Icons.check_circle,
                                            color: Colors.grey)
                                    ],
                                  ),
                                );
                              }).toList() ??
                                  [Text('Пусто')],
                            ),
                            SizedBox(height: 16.0),
                            // Создаем кнопку и устанавливаем ее доступность на основе значения переменной allContainersAccepted
                            Container(
                                child: Column(
                                  children: [
                                    TextButton(
                                      onPressed: allContainersAccepted
                                          ? () async {
                                        if (jsonList.isNotEmpty) {
                                          final Map<String, dynamic>
                                          selectedOrder = jsonList[index];
                                          final dynamic driverIdDynamic =
                                          selectedOrder['driver_id'];
                                          if (driverIdDynamic != null) {
                                            final int driverId =
                                            driverIdDynamic as int;
                                            final int orderId =
                                            selectedOrder['order_id']
                                            as int;
                                            final int pointId =
                                            selectedOrder['point_id']
                                            as int;
                                            context.loaderOverlay.show();
                                            try {
                                              final response =
                                              await _handleButtonPress(
                                                  driverId,
                                                  orderId,
                                                  pointId);
                                              if (response != null &&
                                                  response.containsKey(
                                                      'pdfData')) {
                                                final pdfData =
                                                response['pdfData']
                                                as String;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PdfViewerPage(
                                                          pdfData: pdfData,
                                                          driverId: driverId,
                                                          orderId: orderId,
                                                          pointId: pointId,
                                                        ),
                                                  ),
                                                );
                                                context.loaderOverlay.hide();
                                              } else if (response != null &&
                                                  response
                                                      .containsKey('error')) {
                                                print(response['error']);
                                                context.loaderOverlay.hide();
                                              }
                                            } catch (e) {
                                              print(
                                                  'Ошибка при загрузке данных: $e');
                                              context.loaderOverlay.hide();
                                            }
                                          } else {
                                            print(
                                                'Не удалось получить данные PDF');
                                            context.loaderOverlay.hide();
                                          }
                                        } else {
                                          print('Список jsonList пуст');
                                          context.loaderOverlay.hide();
                                        }
                                      }
                                          : null,
                                      child: Text(
                                        'Посмотреть ТТН',
                                        style: TextStyle(
                                          color: allContainersAccepted
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: allContainersAccepted
                                          ? () async {
                                        late final String url;
                                        if (jsonList.isNotEmpty) {
                                          final Map<String, dynamic>
                                          selectedOrder = jsonList[index];
                                          final dynamic driverIdDynamic =
                                          selectedOrder['driver_id'];
                                          if (driverIdDynamic != null) {
                                            final int driverId =
                                            driverIdDynamic as int;
                                            final int orderId =
                                            selectedOrder['order_id']
                                            as int;
                                            final int pointId =
                                            selectedOrder['point_id']
                                            as int;
                                            final acceptContQrCubit = BlocProvider.of<AcceptContQrCubit>(context);
                                            final authLocalDS = await acceptContQrCubit.getAuthLocalDS();
                                            final User user = await authLocalDS.getUserFromCache();
                                            final response =
                                            await _handleButtonPress(
                                                driverId,
                                                orderId,
                                                pointId);
                                            if (Theme.of(context).platform ==
                                                TargetPlatform.iOS) {
                                              url =
                                              'https://mgovsign.page.link/?link=https://api.sattiway.kz/api/v2/egov/ttn/tsd/mgovSign?order_id%3D$orderId%26driver_id%3D$driverId%26type_sign%3Dtsd%26point_id%3D$pointId'
                                                  '%26signatory%3D${user.login}&isi=1476128386&ibi=kz.egov.mobile';
                                            } else if (Theme.of(context)
                                                .platform ==
                                                TargetPlatform.android) {
                                              url =
                                              'https://mgovsign.page.link/?link=https://api.sattiway.kz/api/v2/egov/ttn/tsd/mgovSign?order_id%3D2604%26driver_id%3D358%26type_sign%3Dtsd%26point_id%3D12244%26signatory%3Dsign_user&apn=kz.mobile.mgov';
                                            }
                                            // Проверяем, можем ли открыть ссылку
                                            if (await canLaunchUrlString(
                                                url)) {
                                              await launchUrlString(url);
                                            } else {
                                              throw 'Could not launch $url';
                                            }
                                          } else {
                                            // Обработка других сценариев ошибок
                                            print(
                                                'Не удалось получить данные PDF');
                                          }
                                        } else {
                                          print('Список jsonList пуст');
                                        }
                                      }
                                          : () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Отсканируйте все контейнеры',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      },
                                      child: Text('Подписать ТТН №$orderNumber',
                                          style: TextStyle(color: Colors.white)),
                                      style: ButtonStyle(
                                        backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                          allContainersAccepted
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _handleButtonPress(
      int driverId, int orderId, int pointId) async {
    try {
      final acceptContQrCubit = BlocProvider.of<AcceptContQrCubit>(context);
      final authLocalDS = await acceptContQrCubit.getAuthLocalDS();
      final User user = await authLocalDS.getUserFromCache();
      context.loaderOverlay.show();
      String url =
          'https://api.sattiway.kz/api/v2/egov/ttnSign/tsd/$driverId/$orderId/$pointId/${user.name}/tsd/mgovSign';
      Response response = await Dio()
          .get(
        url,
        // queryParameters: {'point_id': pointId, "signatory": "Первый подписант"},
      )
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        // Результаты запроса получены успешно
        print('Результаты запроса:');
        print(response.data);
        // Скрываем индикатор загрузки
        context.loaderOverlay.hide();
        // Проверяем, есть ли данные в ответе
        if (response.data != null && response.data is Map<String, dynamic>) {
          final pdfData = response.data['documentsToSign']?.first['document']
          ?['file']?['data'] as String?;
          if (pdfData != null) {
            // Возвращаем данные в случае успеха
            return {'pdfData': pdfData};
          } else {
            // Возвращаем ошибку, если данные не найдены
            return {'error': 'Данные PDF не найдены'};
          }
        } else {
          // Возвращаем ошибку, если данные не получены
          return {'error': 'Данные не получены'};
        }
      } else {
        // Возвращаем информацию об ошибке при выполнении запроса
        print('Ошибка при выполнении запроса: ${response.statusCode}');
        return {
          'error': 'Ошибка при выполнении запроса: ${response.statusCode}'
        };
      }
    } catch (e) {
      // Возвращаем информацию об ошибке при выполнении запроса
      print('Ошибка при выполнении запроса: $e');
      return {'error': 'Ошибка при выполнении запроса: $e'};
    }
  }
}