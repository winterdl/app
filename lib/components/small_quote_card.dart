
import 'package:flutter/material.dart';
import 'package:memorare/types/quote.dart';

class SmallQuoteCard extends StatelessWidget {
  final Quote quote;

  SmallQuoteCard({this.quote});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.0,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 195.0,
            width: 200.0,
            child: Card(
              color: Color(0xFFF1F2F6),
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Center(
                    child: Text(
                      (quote.name.length > 51) ?
                        '${quote.name.substring(0, 51)}...' :
                        quote.name,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}