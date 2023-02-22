import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'DataHandler.dart';

class LeaderboardScreen extends StatefulWidget {

  final DataHandler dh;

  LeaderboardScreen(this.dh);

  LeaderboardScreenState createState() => LeaderboardScreenState(dh);

}

class LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {

  final tabs = ["Times", "Cards left"];
  final DataHandler dh; //deals with the loading and saving of data
  TabController tabControl;

  LeaderboardScreenState(this.dh);

  initState() {
    super.initState();
    tabControl = new TabController(vsync: this, length: 2);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Top ten"),
        centerTitle: true,
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: tabControl,
          isScrollable: false,
          tabs: [
            for (final tab in tabs) Tab(text: tab),
          ],
          onTap: (index) {
            FocusScope.of(context).unfocus();
            tabControl.animateTo(index);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.privacy_tip_outlined),
            onPressed: () async {
              await launchUrl(Uri.parse("https://funkypenguin.dev/projects/policies#elevens"));
            },
            tooltip: "Privacy Policy",
          ),
        ],
      ),
      body: TabBarView(
        controller: tabControl,
        children: [
          getTimesWidget(),
          getCardsWidget(),
        ],
      ),
    );
  }

  ///Returns the widget that holds the user's top 10 times
  Widget getTimesWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          DataTable(
            columns: [
              DataColumn(
                label: Text(
                  "Time",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Date achieved",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
            rows: [
              for (Entry e in dh.times)
                if (e != null)
                  DataRow(
                    cells: [
                      DataCell(Text(
                        e.time,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      )),
                      DataCell(Text(
                        e.dayDone.toString().substring(0, 10),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      )),
                    ],
                  ),
            ],
          ),
        ],
      )
    );
  }

  ///Returns the user's fewest 10 number of cards left
  Widget getCardsWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          DataTable(
            columns: [
              DataColumn(
                label: Text(
                  "Cards left",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Date achieved",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
            rows: [
              for (CardCount c in dh.cards)
                if (c != null)
                  DataRow(
                    cells: [
                      DataCell(Text(
                        c.cardsLeft.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      )),
                      DataCell(Text(
                        c.dayDone.toString().substring(0, 10),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      )),
                    ],
                  ),
            ],
          ),
        ],
      )
    );
  }

}