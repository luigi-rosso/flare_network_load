import 'dart:io';
import 'dart:typed_data';

import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'flare_artboard.dart';

/// Flare controls with a default animation to play on initialization.
class SimpleControls extends FlareControls {
  final String defaultAnimation;
  SimpleControls(this.defaultAnimation);
  @override
  void initialize(FlutterActorArtboard artboard) {
    super.initialize(artboard);
    if (defaultAnimation != null) {
      play(defaultAnimation);
    }
  }
}

/// A Flare widget that loads a file from the network. This could be easily
/// extended to also load the file from an AssetBundle, but the point is to show
/// how to easily comopose Flare widgets using existing Flutter functionality.
class Flare extends StatefulWidget {
  final String filename;
  final String animation;
  final BoxFit fit;
  final Alignment alignment;

  const Flare(
      {Key key,
      this.filename,
      this.animation,
      this.fit = BoxFit.contain,
      this.alignment = Alignment.center})
      : super(key: key);

  @override
  _FlareState createState() => _FlareState();
}

class _FlareState extends State<Flare> {
  FlutterActorArtboard _artboard;
  SimpleControls _controls;

  @override
  void initState() {
    super.initState();
    _controls = SimpleControls(widget.animation);
    _load();
  }

  @override
  void didUpdateWidget(Flare oldWidget) {
    if (oldWidget.filename != widget.filename) {
      _load();
    }
    if (oldWidget.animation != widget.animation) {
      // Simple way to change animation when the widget animation changes
      // Could also mix it by calling .play on the existing controls,
      // or provide your own controller. This is an example, implement as
      // you need!
      setState(() {
        _controls = SimpleControls(widget.animation);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  // Load the flare file from the network, instance the correct artboard, and
  // use it to display the FlareArtboard widget.
  Future<void> _load() async {
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.getUrl(Uri.parse(widget.filename));
    HttpClientResponse response = await request.close();
    var data = await consolidateHttpClientResponseBytes(response);
    var actor = await FlutterActor.loadFromByteData(ByteData.view(data.buffer));
    var artboard = actor.artboard;
    artboard.initializeGraphics();

    var flutterArtboard = artboard.makeInstance() as FlutterActorArtboard;
    flutterArtboard.initializeGraphics();
    flutterArtboard.advance(0);

    setState(() {
      _artboard = flutterArtboard;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If the artboard hasn't loaded yet, just show an empty container.
    // Otherwise show the artboard and pass through alignment and fit
    // options.
    return _artboard == null
        ? Container()
        : FlareArtboard(
            _artboard,
            alignment: widget.alignment,
            fit: widget.fit,
            controller: _controls,
          );
  }
}
