import 'dart:math';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/modules/settings/providers/app_settings.provider.dart';
import 'package:immich_mobile/modules/settings/services/app_settings.service.dart';
import 'package:immich_mobile/shared/providers/asset.provider.dart';
import 'package:openapi/api.dart';

enum RenderAssetGridElementType {
  assetRow,
  dayTitle,
  monthTitle;
}

class RenderAssetGridRow {
  final List<AssetResponseDto> assets;

  RenderAssetGridRow(this.assets);
}

class RenderAssetGridElement {
  final RenderAssetGridElementType type;
  final RenderAssetGridRow? assetRow;
  final String? title;
  final int? month;
  final int? year;
  final List<AssetResponseDto>? relatedAssetList;

  RenderAssetGridElement(
    this.type, {
    this.assetRow,
    this.title,
    this.month,
    this.year,
    this.relatedAssetList,
  });
}

final renderListProvider = StateProvider((ref) {
  var assetGroups = ref.watch(assetGroupByDateTimeProvider);
  var settings = ref.watch(appSettingsServiceProvider);

  final assetsPerRow = settings.getSetting(AppSettingsEnum.tilesPerRow);

  List<RenderAssetGridElement> elements = [];
  DateTime? lastDate;

  assetGroups.forEach((groupName, assets) {
    final date = DateTime.parse(groupName);

    if (lastDate == null || lastDate!.month != date.month) {
      elements.add(
        RenderAssetGridElement(RenderAssetGridElementType.monthTitle,
            title: groupName, month: date.month, year: date.year),
      );
    }

    // Add group title
    elements.add(
      RenderAssetGridElement(
        RenderAssetGridElementType.dayTitle,
        title: groupName,
        month: date.month,
        year: date.year,
        relatedAssetList: assets,
      ),
    );

    // Add rows
    int cursor = 0;
    while (cursor < assets.length) {
      int rowElements = min(assets.length - cursor, assetsPerRow);

      final rowElement = RenderAssetGridElement(
        RenderAssetGridElementType.assetRow,
        month: date.month,
        year: date.year,
        assetRow: RenderAssetGridRow(
          assets.sublist(cursor, cursor + rowElements),
        ),
      );

      elements.add(rowElement);
      cursor += rowElements;
    }

    lastDate = date;
  });

  return elements;
});