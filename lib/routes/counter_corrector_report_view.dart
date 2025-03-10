import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/routes/counter_corrector_reports.dart';
import 'package:tmms_shifts_client/routes/page_not_found_route.dart';

class CounterCorrectorReportViewRoute extends StatefulWidget {
  static const routingName = "CounterCorrectorReportViewRoute";

  final int report;

  const CounterCorrectorReportViewRoute({super.key, required this.report});

  @override
  State<CounterCorrectorReportViewRoute> createState() =>
      _CounterCorrectorReportViewRouteState();
}

class _CounterCorrectorReportViewRouteState
    extends State<CounterCorrectorReportViewRoute> {
  final _stationCodeController = TextEditingController();
  final _userController = TextEditingController();
  final _dateController = TextEditingController();
  final _registeredDateController = TextEditingController();
  final List<RanTextControllers> _ranControllers = [];
  final List<Ran2> _tempRansInEdit = [];

  static const titleSize = 24.0;

  bool _editing = false;

  Future<GetMeterAndCorrectorFullReportResponseResultItem> getReport(
    int reportId,
  ) async {
    await Future.delayed(Duration(seconds: 2));
    if (reportId > mockResults.results.length) {
      return Future.error("Report doesn't exist");
    } else {
      return mockResults.results[reportId];
    }
  }

  Widget titleAndTextFieldRow(String title, TextEditingController controller) {
    return SizedBox(
      height: 80,
      child: Row(
        spacing: 32,
        children: [
          SizedBox(
            width: 200,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(fontSize: titleSize),
                textAlign: TextAlign.end,
              ),
            ),
          ),
          SizedBox(
            width: 400,
            child: TextField(
              enabled: _editing,
              controller: controller,
              decoration: InputDecoration(hintText: title, labelText: title),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(iconAssetPath), context);
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("گزارش شماره ${widget.report}"),
          centerTitle: true,
        ),
        body: FutureBuilder(
          initialData: null,
          future: getReport(widget.report),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.goNamed(PageNotFoundRoute.routingName);
              });
              return Container();
            } else {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                final data = snapshot.data!;
                _stationCodeController.text = data.stationCode.toString();
                _userController.text = data.user ?? "";
                _dateController.text = data.date;
                _registeredDateController.text = data.registeredDatetime ?? "";

                final List<Widget> ransWidgetsList = [];
                final List<Ran2> ransList;
                if (_editing) {
                  ransList = _tempRansInEdit;
                } else {
                  ransList = data.rans;
                }
                for (var i = 0; i < ransList.length; i++) {
                  final ran = ransList[i];
                  final meterAmountController = TextEditingController(
                    text: ran.meterAmount.toString(),
                  );
                  final correctorAmountController = TextEditingController(
                    text: ran.correctorAmount.toString(),
                  );
                  final correctorAndMeterAmountController =
                      TextEditingController(
                        text: ran.correctorMeterAmount.toString(),
                      );
                  final ranSequenceController = TextEditingController(
                    text: ran.ranSequence.toString(),
                  );
                  final ranController = TextEditingController(
                    text: ran.ran.toString(),
                  );
                  final ranTextControllers = RanTextControllers(
                    meterAmountController: meterAmountController,
                    correctorMeterAmountController:
                        correctorAndMeterAmountController,
                    correctorAmountController: correctorAmountController,
                    ranSequenceController: ranSequenceController,
                    ranController: ranController,
                  );
                  _ranControllers.add(ranTextControllers);
                  ransWidgetsList.addAll([
                    Row(
                      children: [
                        SizedBox(width: _editing ? 350 : 400),
                        if (_editing)
                          SizedBox(
                            width: 50,
                            child: IconButton(
                              color: Colors.red,
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _tempRansInEdit.removeAt(i);
                                });
                                _ranControllers[i].dispose();
                                _ranControllers.removeAt(i);
                              },
                            ),
                          ),
                        Text(
                          "Ran ${ran.ranSequence}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: titleAndTextFieldRow(
                            "مقدار کنتور",
                            ranTextControllers.meterAmountController,
                          ),
                        ),
                        Expanded(
                          child: titleAndTextFieldRow(
                            "مقدار تصحیح کننده",
                            ranTextControllers.correctorAmountController,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: titleAndTextFieldRow(
                            "مقدار کنتور و تصحیح کننده",
                            ranTextControllers.correctorMeterAmountController,
                          ),
                        ),
                        Expanded(
                          child: titleAndTextFieldRow(
                            "ترتیب ران",
                            ranTextControllers.ranSequenceController,
                          ),
                        ),
                      ],
                    ),
                    titleAndTextFieldRow(
                      "ران",
                      ranTextControllers.ranController,
                    ),
                  ]);
                }

                final List<Widget> bottomRow = [];
                if (!_editing) {
                  bottomRow.add(
                    ElevatedButton(
                      onPressed: () {
                        _tempRansInEdit.addAll(
                          mockResults.results[widget.report].rans,
                        );
                        _editing = true;
                        setState(() {});
                      },
                      child: Row(
                        spacing: 16,
                        children: [
                          Icon(Icons.edit_rounded, size: 24),
                          Text("ویرایش", style: TextStyle(fontSize: 24)),
                        ],
                      ),
                    ),
                  );
                } else {
                  bottomRow.addAll([
                    TextButton(
                      onPressed: () {
                        _editing = false;
                        _tempRansInEdit.clear();
                        final reportItem = mockResults.results[widget.report];
                        _stationCodeController.text =
                            reportItem.stationCode.toString();
                        _userController.text = reportItem.user ?? "";
                        _dateController.text = reportItem.date;
                        _registeredDateController.text =
                            reportItem.registeredDatetime ?? "";
                        for (var i = 0; i < reportItem.rans.length; i++) {
                          final ran = reportItem.rans[i];
                          _ranControllers[i].meterAmountController.text =
                              ran.meterAmount.toString();
                          _ranControllers[i].correctorAmountController.text =
                              ran.correctorAmount.toString();
                          _ranControllers[i]
                              .correctorMeterAmountController
                              .text = ran.correctorMeterAmount.toString();
                          _ranControllers[i].ranSequenceController.text =
                              ran.ranSequence.toString();
                          _ranControllers[i].ranController.text =
                              ran.ran.toString();
                        }
                        for (var i = 0; i < _ranControllers.length; i++) {
                          if (i >= reportItem.rans.length) {
                            _ranControllers[i].dispose();
                            _ranControllers.removeAt(i);
                          }
                        }

                        setState(() {});
                      },
                      child: Row(
                        spacing: 16,
                        children: [
                          Icon(Icons.cancel, size: 24),
                          Text("لغو", style: TextStyle(fontSize: 24)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        spacing: 16,
                        children: [
                          Icon(Icons.send, size: 24),
                          Text("ارسال", style: TextStyle(fontSize: 24)),
                        ],
                      ),
                    ),
                  ]);
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 32,
                      children: [
                        SizedBox(),
                        Center(
                          child: Image.asset(
                            iconAssetPath,
                            width: 200,
                            height: 200,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: titleAndTextFieldRow(
                                "کد ایستگاه",
                                _stationCodeController,
                              ),
                            ),
                            Expanded(
                              child: titleAndTextFieldRow(
                                "کاربر",
                                _userController,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: titleAndTextFieldRow(
                                "تاریخ",
                                _dateController,
                              ),
                            ),
                            Expanded(
                              child: titleAndTextFieldRow(
                                "تاریخ ثبت",
                                _registeredDateController,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Ran ها:",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...ransWidgetsList,
                        SizedBox(height: 16),
                        if (_editing)
                          SizedBox(
                            height: 100,
                            child: Center(
                              child: IconButton(
                                onPressed: () {
                                  _tempRansInEdit.add(
                                    Ran2(
                                      meterAmount: 0,
                                      correctorAmount: 0,
                                      correctorMeterAmount: 0,
                                      ranSequence: 0,
                                      ran: 0,
                                    ),
                                  );
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 80,
                          child: Row(
                            spacing: 32,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [...bottomRow],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stationCodeController.dispose();
    _userController.dispose();
    _dateController.dispose();
    _registeredDateController.dispose();
    for (final item in _ranControllers) {
      item.dispose();
    }
    super.dispose();
  }
}

class RanTextControllers {
  final TextEditingController meterAmountController;
  final TextEditingController correctorAmountController;
  final TextEditingController correctorMeterAmountController;
  final TextEditingController ranSequenceController;
  final TextEditingController ranController;

  const RanTextControllers({
    required this.meterAmountController,
    required this.correctorAmountController,
    required this.correctorMeterAmountController,
    required this.ranSequenceController,
    required this.ranController,
  });

  void dispose() {
    meterAmountController.dispose();
    correctorAmountController.dispose();
    correctorMeterAmountController.dispose();
    ranSequenceController.dispose();
    ranController.dispose();
  }
}
