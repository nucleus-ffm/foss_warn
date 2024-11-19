import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' hide TileLayer;

import '../class/abstract_Place.dart';
import '../class/class_Area.dart';
import '../class/class_WarnMessage.dart';
import '../services/listHandler.dart';

class vectorMapWidget extends StatefulWidget {
  final List<PolygonLayer>? polygonLayers;
  final List<MarkerLayer>? markerLayers;
  final List<Widget>? widgets;
  final MapController mapController;
  final CameraFit initialCameraFit;
  const vectorMapWidget(
      {super.key,
      this.polygonLayers,
      this.markerLayers,
      this.widgets,
      required this.mapController,
      required this.initialCameraFit});

  @override
  State<vectorMapWidget> createState() => _vectorMapWidgetState();

  /// create polygon layer for my places alerts
  static List<PolygonLayer> createPolygonLayer() {
    List<PolygonLayer> result = [];
    for (Place p in myPlaceList) {
      for (WarnMessage wm in p.warnings) {
        result.add(
          PolygonLayer(
            polygons: Area.createListOfPolygonsForAreas(wm.info.first.area),
          ),
        );
      }
    }
    return result;
  }

  static List<PolygonLayer> createPolygonsForMapWarning() {
    List<PolygonLayer> result = [];
    for (WarnMessage wm in mapWarningsList) {
      result.add(
        PolygonLayer(
          polygonCulling: true,
          polygons: Area.createListOfPolygonsForAreas(wm.info.first.area),
        ),
      );
    }
    return result;
  }
}

class _vectorMapWidgetState extends State<vectorMapWidget> {
  Style? _style;
  Object? _error;

  // alternates:
  //   Mapbox - mapbox://styles/mapbox/streets-v12?access_token={key}
  //   Maptiler - https://api.maptiler.com/maps/outdoor/style.json?key={key}
  //   Stadia Maps - https://tiles.stadiamaps.com/styles/outdoors.json?api_key={key}
  Future<Style> _readStyle() => StyleReader(
          uri: 'https://tileserver.gnome.org/styles/basic-preview/style.json',
          // ignore: undefined_identifier
          logger: const Logger.console())
      .read();

  Widget _statusText() => Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: StreamBuilder(
          stream: widget.mapController.mapEventStream,
          builder: (context, snapshot) {
            return Text(
                'Zoom: ${widget.mapController.camera.zoom.toStringAsFixed(2)} Center: ${widget.mapController.camera.center.latitude.toStringAsFixed(4)},${widget.mapController.camera.center.longitude.toStringAsFixed(4)}');
          }));

  @override
  void initState() {
    super.initState();
    _initStyle();
  }

  void _initStyle() async {
    try {
      _style = await _readStyle();
    } catch (e, stack) {
      // ignore: avoid_print
      print(e);
      // ignore: avoid_print
      print(stack);
      _error = e;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    while (_style == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.flingAnimation | InteractiveFlag.doubleTapZoom),
        initialCameraFit: widget.initialCameraFit,
        //initialZoom: _style?.zoom ?? 10,
        maxZoom: 22,
        //backgroundColor: material.Theme.of(context).canvasColor
      ),
      children: [
        VectorTileLayer(
            tileProviders: _style!.providers,
            theme: _style!.theme,
            sprites: _style!.sprites,
            maximumZoom: 22,
            tileOffset: TileOffset.mapbox,
            layerMode: VectorTileLayerMode.vector),
        ...widget.polygonLayers ?? [],
        ...widget.markerLayers ?? [],
        ...widget.widgets ?? [],
        SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
      ],
    );
  }
}
