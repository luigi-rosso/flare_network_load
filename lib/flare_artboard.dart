import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_render_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/aabb.dart';
import 'package:flare_flutter/flare_controller.dart';

class FlareArtboard extends LeafRenderObjectWidget {
  final FlutterActorArtboard artboard;
  final BoxFit fit;
  final Alignment alignment;
  final FlareController controller;

  const FlareArtboard(this.artboard,
      {this.fit = BoxFit.contain,
      this.alignment = Alignment.center,
      this.controller});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return FlareArtboardRenderObject()
      ..artboard = artboard
      ..fit = fit
      ..controller = controller
      ..alignment = alignment;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant FlareArtboardRenderObject renderObject) {
    renderObject
      ..artboard = artboard
      ..fit = fit
      ..controller = controller
      ..alignment = alignment;
  }

  @override
  void didUnmountRenderObject(
      covariant FlareArtboardRenderObject renderObject) {
    renderObject.dispose();
  }
}

class FlareArtboardRenderObject extends FlareRenderBox {
  FlutterActorArtboard _artboard;
  AABB _setupAABB;
  FlareController _controller;
  FlareController get controller => _controller;
  set controller(FlareController c) {
    if (_controller != c) {
      _controller?.isActive?.removeListener(onControllerActiveChange);
      _controller = c;
      _controller?.isActive?.addListener(onControllerActiveChange);
      if (_controller != null && _artboard != null) {
        _controller.initialize(_artboard);
      }
    }
  }

  void onControllerActiveChange() {
    updatePlayState();
  }

  void updateBounds() {
    if (_artboard != null) {
      _setupAABB = _artboard.artboardAABB();
    }
  }

  FlutterActorArtboard get artboard => _artboard;
  set artboard(FlutterActorArtboard value) {
    if (value == _artboard) {
      return;
    }
    _artboard = value;

    //load();
    if (_artboard != null) {
      updateBounds();

      _controller?.initialize(_artboard);
    }
    markNeedsPaint();
  }

  @override
  void advance(double elapsedSeconds) {
    if (_artboard != null &&
        _controller != null &&
        !_controller.advance(_artboard, elapsedSeconds)) {
      _controller?.isActive?.value = false;
    }

    if (_artboard != null) {
      _artboard.advance(elapsedSeconds);
    }
  }

  @override
  AABB get aabb => _setupAABB;

  @override
  void prePaint(Canvas canvas, Offset offset) {
    canvas.clipRect(offset & size);
  }

  @override
  void paintFlare(Canvas canvas, Mat2D viewTransform) {
    if (_artboard == null) {
      return;
    }

    _artboard.draw(canvas);
  }

  @override
  bool get isPlaying => true;

  @override
  Future<void> load() {
    return null;
  }
}
