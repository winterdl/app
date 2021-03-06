import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/pagination.dart';
import 'package:memorare/types/quotes_list.dart';
import 'package:provider/provider.dart';

enum ButtonType {
  icon,
  tile,
}

class AddToListButton extends StatefulWidget {
  final BuildContext context;
  final Function onBeforeShowSheet;
  final String quoteId;
  final ButtonType type;
  final double size;

  AddToListButton({
    this.context,
    this.onBeforeShowSheet,
    this.quoteId,
    this.size = 30.0,
    this.type = ButtonType.icon
  });

  @override
  _AddToListButtonState createState() => _AddToListButtonState();
}

class _AddToListButtonState extends State<AddToListButton> {
  List<QuotesList> lists = [];

  String newListName = '';
  String newListDescription = '';

  int order = -1;

  bool isLoading = false;
  bool isLoadingMoreList = false;
  bool isLoaded = false;
  bool hasErrors = false;
  Error error;

  Pagination pagination = Pagination();

  @override
  Widget build(BuildContext context) {
    return widget.type == ButtonType.icon ?
      IconButton(
        iconSize: widget.size,
        icon: Icon(
          Icons.playlist_add,
        ),
        onPressed: () {
          if (widget.onBeforeShowSheet != null) {
            widget.onBeforeShowSheet();
          }

          showBottomSheetList();
        },
      ):
      ListTile(
        onTap: () {
          if (widget.onBeforeShowSheet != null) {
            widget.onBeforeShowSheet();
          }

          showBottomSheetList();
        },
        leading: Icon(Icons.playlist_add),
        title: Text(
          'Add to...',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      );
  }

  void showBottomSheetList() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            List<Widget> tiles = [];

            if (hasErrors) {
              tiles.add(
                errorTileList(onPressed: () async {
                  await fetchLists();
                  setSheetState(() { isLoaded = true; });
                })
              );
            }

            if (lists.length == 0 && !isLoading && !isLoaded) {
              tiles.add(LinearProgressIndicator());

              fetchLists().then((_) {
                setSheetState(() { isLoaded = true; });
              });
            }

            if (lists.length > 0) {
              for (var list in lists) {
                tiles.add(tileList(list));
              }
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollNotif) {
                if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
                  return false;
                }

                if (pagination.hasNext && !isLoadingMoreList) {
                  fetchMoreLists()
                    .then((_) {
                      setSheetState(() {
                        isLoadingMoreList = false;
                      });
                    });
                }

                return false;
              },
              child: ListView(
                children: <Widget>[
                  newListButton(),
                  Divider(),
                  ...tiles
                ],
              ),
            );
          },
        );
      }
    );
  }

  Widget tileList(QuotesList list) {
    final _context = widget.context ?? context;

    return ListTile(
      onTap: () {
        addQuoteToList(
          context: context,
          listId: list.id,
          listName: list.name
        );

        Navigator.pop(_context);
      },
      title: Text(
        list.name,
      ),
    );
  }

  Widget newListButton() {
    return ListTile(
      onTap: () async {
        final res = await showNewListDialog(context);
        if (res != null && res) { Navigator.pop(context); }
      },
      leading: Icon(Icons.add),
      title: Text(
        'New list',
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
    );
  }

  Widget errorTileList({Function onPressed}) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Text(
            'There was an issue while loading your lists.'
          ),
          FlatButton(
            onPressed: () {
              if (onPressed != null) {
                onPressed();
              }
            },
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('Retry'),
            ),
          )
        ],
      ),
    );
  }

  Future fetchLists() {
    isLoading = true;
    pagination = Pagination();

    return Queries
    .lists(
      context: context,
      limit: pagination.limit,
      order: order,
      skip: pagination.skip,

    ).then((resp) {
      isLoading = false;
      isLoaded = true;

      lists = resp.entries;
      pagination = resp.pagination;

    }).catchError((err) {
      error = err;
      hasErrors = true;
      isLoading = false;
      isLoaded = true;
    });
  }

  Future fetchMoreLists() {
    isLoadingMoreList = true;

    return Queries
      .lists(
        context: context,
        limit: pagination.limit,
        order: order,
        skip: pagination.nextSkip,

      ).then((resp) {
        isLoadingMoreList = false;
        pagination = resp.pagination;
        lists.addAll(resp.entries);

      }).catchError((err) {
        isLoadingMoreList = false;
      });
  }

  Future<bool> showNewListDialog(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Create a new list'
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          children: <Widget>[
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: accent),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: accent,
                    width: 2.0
                  ),
                ),
              ),
              onChanged: (newValue) {
                newListName = newValue;
              },
            ),
            Padding(padding: EdgeInsets.only(top: 10.0),),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: accent),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: accent,
                    width: 2.0
                  ),
                ),
              ),
              onChanged: (newValue) {
                newListDescription = newValue;
              },
            ),
            Padding(padding: EdgeInsets.only(top: 20.0),),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    return Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'Cancel',
                  ),
                ),

                RaisedButton(
                  color: accent,
                  onPressed: () {
                    createNewList(context);
                    return Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        );
      }
    );
  }

  void addQuoteToList({BuildContext context, String listId, String listName}) {
    final _context = widget.context ?? context;

    Mutations
    .addUniqToList(_context, listId, widget.quoteId)
    .then((resp) {
      if (resp.boolean) {
        Flushbar(
          duration: Duration(seconds: 3),
          backgroundColor: ThemeColor.success,
          message: 'Added to the list $listName.',
        )..show(_context);
        return;
      }

      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: ThemeColor.error,
        message: resp.message,
      )..show(_context);
    });
  }

  void createNewList(BuildContext context) {
    final _context = widget.context ?? context;

    Mutations
    .createList(
      context: context,
      name: newListName,
      description: newListDescription,
      quoteId: widget.quoteId,
    ).then((quotesListResp) {
      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: ThemeColor.success,
        message: 'Your new list $newListName has been created.',
      )..show(_context);
    })
    .catchError((err) {
      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: ThemeColor.error,
        message: 'Could not create your new list. Try again later or contact us.',
      )..show(_context);
    });
  }
}
