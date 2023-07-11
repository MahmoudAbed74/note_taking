import 'package:flutter/material.dart';

class view_note extends StatefulWidget {
  // Receive notes data from previous screen
  var notes;
  view_note({
    this.notes,
  });

  @override
  State<view_note> createState() => _view_noteState();
}

class _view_noteState extends State<view_note> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" View note"),
        centerTitle: true,
      ),
      body: Column(children: [
        // Show note image
        Container(
          width: double.infinity,
          height: 200,
          child:
              Image.network("${widget.notes['url image']}", fit: BoxFit.fill),
        ),
        SizedBox(
          height: 10,
        ),
        // Show note title
        Container(
          child: Center(
            child: Text("${widget.notes["Title Note"]}",
                style: Theme.of(context).textTheme.bodyLarge),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        // Show note body
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text("${widget.notes["Body Note"]}",
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        // Show last edit time
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text("last edit:  ${widget.notes["time"]}",
              style: Theme.of(context).textTheme.headlineSmall),
        )
      ]),
    );
  }
}
