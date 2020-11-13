import 'package:flutter/material.dart';

import 'DataHandler.dart';

class LeaderboardScreen extends StatefulWidget {

  final DataHandler dh;

  LeaderboardScreen(this.dh);

  LeaderboardScreenState createState() => LeaderboardScreenState(dh);

}

class LeaderboardScreenState extends State<LeaderboardScreen> {

  final DataHandler dh;

  LeaderboardScreenState(this.dh);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Top ten times"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: DataTable(
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
            ),
          ],
        ),
      ),
    );
  }

}