import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:covid19cuba/src/utils/utils.dart';
import 'package:covid19cuba/src/models/data_model.dart';

import 'dart:developer';
import 'dart:convert';

String mapdata="{}";

/*void LogPrint(Object object) {
    int defaultPrintLength = 1020;
    if (object == null || object.toString().length <= defaultPrintLength) {
       print(object);
    } else {
       String log = object.toString();
       int start = 0;
       int endIndex = defaultPrintLength;
       int logLength = log.length;
       int tmpLogLength = log.length;
       while (endIndex < logLength) {
          print(log.substring(start, endIndex));
          endIndex += defaultPrintLength;
          start += defaultPrintLength;
          tmpLogLength -= defaultPrintLength;
       }
       if (tmpLogLength > 0) {
          print(log.substring(start, logLength));
       }
    }

}*/

class MapWebViewWidget extends StatelessWidget {

  final DataModel data;
  MapWebViewWidget({this.data}) : assert(data != null);

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  WebViewController cont;
  String selecte_view = 'Provincia';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Center(
            child: Text(
              'Distribución por $selecte_view',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Constants.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        Container(
          height: 300,
           margin: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
          ),
          // constraints: Constrains,
          child: WebView(
              initialUrl: 'assets/map.html',
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (_) {
                mapdata=jsonEncode(data.cases.toJson());
                //LogPrint(mapdata);
                cont
                    .evaluateJavascript('covidData($mapdata)')
                    .whenComplete((){
                        print('Mapa injected');
                        cont
                        .evaluateJavascript("\$('#map-mun').hide();\$('#map-pro').show();")
                        .whenComplete((){
                          print('Change to province map');
                          selecte_view = 'Provincia';
                        });
                      }
                    );
              },
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
                cont = webViewController;
                                //cont
                //    .evaluateJavascript('covidData($basedata)')
                //    .whenComplete(() => print('Mapa injected'));

              }),
        ),
        ButtonBar(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(
                color: Constants.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                onPressed: () {
                  cont
                        .evaluateJavascript("\$('#map-mun').hide();\$('#map-pro').show();")
                        .whenComplete(() => print('Change to province map'));
                  selecte_view = 'Provincia';
                  (context as Element).markNeedsBuild();
                },
                child: Text("Provincia",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FlatButton(
                color: Constants.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                onPressed: () {
                  cont
                        .evaluateJavascript("\$('#map-pro').hide();\$('#map-mun').show();")
                        .whenComplete(() => print('Change to municipality map'));
                  selecte_view = 'Municipio';
                  (context as Element).markNeedsBuild();
                },
                child: Text("Municipio",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]
        )
      ],
    );
  }
}