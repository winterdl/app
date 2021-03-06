import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';

class DiscoverCard extends StatelessWidget {
  final String id;
  final String name;
  final String summary;
  final String type;

  DiscoverCard({
    this.id,
    this.name = '',
    this.summary = '',
    this.type = 'reference',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        height: 440.0,
        width: 270.0,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: InkWell(
            onTap: () {
              final route = type == 'reference' ?
                ReferenceRoute.replaceFirst(':id', id) :
                AuthorRoute.replaceFirst(':id', id);

              FluroRouter.router.navigateTo(
                context,
                route,
              );
            },
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Opacity(
                        opacity: .7,
                        child: Text(
                          name.length < 21 ?
                            name : '${name.substring(0, 20)}...',
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Opacity(
                            opacity: .5,
                            child: Text(
                              summary.length < 90 ?
                              summary : '${summary.substring(0, 90)}...',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          )
                        ),
                    ],
                  ),

                  Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child: Opacity(
                      opacity: .6,
                      child: type == 'reference' ?
                        Image.asset('assets/images/textbook-${stateColors.iconExt}.png', width: 50.0) :
                        Image.asset('assets/images/profile-${stateColors.iconExt}.png', width: 50.0,),
                    )
                  ),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}
