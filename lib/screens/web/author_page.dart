import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/full_page_error.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/components/web/horizontal_card.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/router/router.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supercharged/supercharged.dart';

class AuthorPage extends StatefulWidget {
  final String id;

  AuthorPage({
    this.id,
  });

  @override
  _AuthorPageState createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  final beginY    = 100.0;
  final delay     = 1.0;
  final delayStep = 1.2;

  Author author;
  Quote quote;
  bool isLoading = false;

  @override
  initState() {
    super.initState();
    fetchAuthor();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return FullPageLoading(title: 'Loading author...');
    }

    if (!isLoading && author == null) {
      return FullPageError(
        message: 'An error occurred while loading author.'
      );
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              // !NOTE: BlendMode does not seem to work on flutter web atm.
              // Container(
              //   color: Colors.black,
              //   height: MediaQuery.of(context).size.height,
              //   width: MediaQuery.of(context).size.width,
              //   child: Opacity(
              //     opacity: .8,
              //     child: Image.asset(
              //       '',
              //       color: Colors.grey,
              //       fit: BoxFit.cover,
              //       height: MediaQuery.of(context).size.height,
              //       width: MediaQuery.of(context).size.width,
              //       colorBlendMode: BlendMode.saturation,
              //     ),
              //   )
              // ),

              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(60.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            FluroRouter.router.pop(context);
                          },
                          icon: Icon(Icons.arrow_back,),
                        )
                      ],
                    ),

                    FadeInY(
                      beginY: beginY,
                      child: Padding(
                        padding: EdgeInsets.only(top: 100.0),
                        child: avatar(),
                      ),
                    ),

                    FadeInY(
                      beginY: beginY,
                      delay: delay + (1 * delayStep),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text(
                          author.name,
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    ControlledAnimation(
                      delay: 1.seconds,
                      duration: 1.seconds,
                      tween: Tween(begin: 0.0, end: 100.0),
                      builder: (_, value) {
                        return SizedBox(
                          width: value,
                          child: Divider(
                            thickness: 1.0,
                            height: 50.0,
                          ),
                        );
                      },
                    ),

                    FadeInY(
                      beginY: beginY,
                      delay: delay + (2 * delayStep),
                      child: Opacity(
                        opacity: .8,
                        child: Text(
                          author.job,
                          style: TextStyle(
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),

        Divider(
          thickness: 1.0,
        ),

        summary(),

        quoteCard(),

        externalLinks(),

        NavBackFooter(),
      ],
    );
  }

  Widget avatar() {
    if (author.urls.image != null && author.urls.image.length > 0) {
      return Material(
        elevation: 1.0,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Ink.image(
          image: NetworkImage(author.urls.image),
          fit: BoxFit.cover,
          width: 200.0,
          height: 200.0,
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Container(
                      height: 500.0,
                      width: 500.0,
                      child: Image(
                        image: NetworkImage(author.urls.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
              );
            },
          ),
        ),
      );
    }

    return Material(
      elevation: 1.0,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Image.asset(
            'assets/images/user-${stateColors.iconExt}.png',
            width: 80.0,
          ),
        ),
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Container(
                  height: 500.0,
                  width: 500.0,
                  child: Image(
                    image: AssetImage('assets/images/user-${stateColors.iconExt}.png',),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
          );
        },
      ),
    );
  }

  Widget externalLinks() {
    final children = <Widget>[];

    if (author.urls.wikipedia != null &&
      author.urls.wikipedia.length > 0) {

      children.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 200.0,
            height: 240.0,
            child: Card(
              child: InkWell(
                onTap: () {
                  launch(author.urls.wikipedia);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: Icon(
                          IconsMore.wikipedia_w,
                          size: 30.0,
                        ),
                      ),
                      Text(
                        'Wikipedia',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      );
    }

    if (author.urls.website != null &&
      author.urls.website.length > 0) {

      children.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 200.0,
            height: 240.0,
            child: Card(
              child: InkWell(
                onTap: () {
                  launch(author.urls.website);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: Icon(
                          IconsMore.earth,
                          size: 30.0,
                        ),
                      ),
                      Text(
                        'Website',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ),
        )
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                'EXTERNAL LINKS'
              ),
            )
          ),

          SizedBox(
            width: 100,
            child: Divider(thickness: 1.0,)
          ),

          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Wrap(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget quoteCard() {
    if (quote == null) {
      return Padding(padding: EdgeInsets.zero,);
    }

    return Container(
      child: Column(
        children: <Widget>[
          Divider(
            thickness: 1.0,
          ),

          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                'QUOTES'
              ),
            )
          ),

          SizedBox(
            width: 100,
            child: Divider(thickness: 1.0,)
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: HorizontalCard(
              quoteId: quote.id,
              quoteName: quote.name,
              referenceId: quote.mainReference.id,
              referenceName: quote.mainReference.name,
            ),
          ),

          Divider(
            thickness: 1.0,
          ),
        ],
      ),
    );
  }

  Widget summary() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Opacity(
            opacity: .6,
            child: Text(
              'SUMMARY'
            ),
          )
        ),

        SizedBox(
          width: 100,
          child: Divider(thickness: 1.0,)
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 100.0
          ),
          child: SizedBox(
            width: 600.0,
            child: Opacity(
              opacity: .7,
              child: Text(
                author.summary,
                style: TextStyle(
                  fontSize: 25.0,
                  height: 1.5,
                )
              ),
            ),
          )
        ),
      ],
    );
  }

  void fetchAuthor() async {
    setState(() {
      isLoading = true;
    });

    try {
      final doc = await Firestore.instance
        .collection('authors')
        .document(widget.id)
        .get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final _author = Author.fromJSON(doc.data);

      setState(() {
        author = _author;
        isLoading = false;
      });

      fetchQuote();

    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchQuote() async {
    if (author == null) { return; }

    try {
      final snapshot = await Firestore.instance
        .collection('quotes')
        .where('author.name', isEqualTo: author.name)
        .limit(1)
        .getDocuments();

      if (snapshot.documents.isEmpty) { return; }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;
        quote = Quote.fromJSON(data);
      });

      setState(() {});

    } catch (error) {
      print(error);
    }
  }
}
