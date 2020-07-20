import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vacemedia_library/api/data_api.dart';
import 'package:vacemedia_library/models/live_show.dart';
import 'package:vacemedia_library/util/functions.dart';

import './call.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();
  List<Channel> _channels = [];

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole _role = ClientRole.Audience;

  @override
  void initState() {
    super.initState();
    _getChannels();
  }

  void _getChannels() async {
    _channels = await DatabaseAPI.getChannels();
    setState(() {});
  }

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VaceMedia Audience',
          style: Styles.whiteSmall,
        ),
      ),
      backgroundColor: Colors.brown[100],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView.builder(
                itemCount: _channels.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('${_channels.elementAt(index).name}'),
                    ),
                  );
                }),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              width: 280,
              height: 180,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: _channelController,
                          decoration: InputDecoration(
                            errorText: _validateError
                                ? 'Channel name is mandatory'
                                : null,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                            hintText: 'Channel name',
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: <Widget>[
                            RaisedButton(
                              onPressed: onJoin,
                              child: Text('Join Channel'),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            )
                          ],
                        )
                      ],
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

  Future<void> onJoin() async {
    // update input validation
    print('🐳🐳🐳🐳🐳 onJoin .................');
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic();
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: _channelController.text,
            role: _role,
          ),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic() async {
//    await PermissionHandler().requestPermissions(
//      [PermissionGroup.camera, PermissionGroup.microphone],
//    );
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.camera,
      Permission.microphone
    ].request();
    print('Permission Status:  🌸 🌸 🌸 $statuses');
  }
}
