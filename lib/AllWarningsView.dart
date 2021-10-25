import 'package:flutter/material.dart';
import 'package:foss_warn/services/markWarningsAsRead.dart';
import 'main.dart';
import 'services/GetData.dart';
import 'services/listHandler.dart';
import 'widgets/WarnCard.dart';
import 'services/saveAndLoadSharedPreferences.dart';

class AllWarningsView extends StatefulWidget {
  const AllWarningsView({Key? key}) : super(key: key);

  @override
  _AllWarningsViewState createState() => _AllWarningsViewState();
}

class _AllWarningsViewState extends State<AllWarningsView> {
  var data;
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (firstStart) {
      loading = true;
      firstStart = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> reloadData() async {
      setState(() {
        loading = true;
      });
      //
    }

    void loadData() async {
      data = await getData();
      loadNotificationSettingsImportanceList();
      setState(() {
        loading = false;
      });
    }

    if (loading == true) {
      loadData();
    }
    while (loading) {
      // show loading screen
      return Center(
        child: SizedBox(
          height: 70,
          width: 70,
          child: CircularProgressIndicator(
            strokeWidth: 4,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: reloadData,
      child: SingleChildScrollView(
        child: Column(
          children: warnMessageList
              .map((warnMessage) => WarnCard(warnMessage: warnMessage))
              .toList(),
        ),
      ),
    );
  }
}
