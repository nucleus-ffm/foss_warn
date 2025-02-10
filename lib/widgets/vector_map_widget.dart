import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' hide TileLayer;

import '../class/class_area.dart';
import '../class/class_warn_message.dart';
import '../services/list_handler.dart';

class VectorMapWidget extends StatefulWidget {
  final List<PolygonLayer>? polygonLayers;
  final List<MarkerLayer>? markerLayers;
  final List<Widget>? widgets;
  final MapController mapController;
  final CameraFit initialCameraFit;
  const VectorMapWidget(
      {super.key,
      this.polygonLayers,
      this.markerLayers,
      this.widgets,
      required this.mapController,
      required this.initialCameraFit});

  @override
  State<VectorMapWidget> createState() => _VectorMapWidgetState();

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

class _VectorMapWidgetState extends State<VectorMapWidget> {
  Style? _style;

  // alternates:
  //   Mapbox - mapbox://styles/mapbox/streets-v12?access_token={key}
  //   Maptiler - https://api.maptiler.com/maps/outdoor/style.json?key={key}
  //   Stadia Maps - https://tiles.stadiamaps.com/styles/outdoors.json?api_key={key}
  Future<Style> _readStyle() => StyleReader(
          uri: 'https://tileserver.gnome.org/styles/basic-preview/style.json',
          // ignore: undefined_identifier
          logger: const Logger.console())
      .read();

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
            flags: InteractiveFlag.pinchZoom |
                InteractiveFlag.drag |
                InteractiveFlag.flingAnimation |
                InteractiveFlag.doubleTapZoom),
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
