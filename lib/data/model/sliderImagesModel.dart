///Same model is used for the Slider Image & banner of featured sections in Home Screen
class SliderImage {
  SliderImage({
    required this.id,
    required this.type,
    required this.typeId,
    required this.sliderImage,
    required this.categoryName,
    required this.providerName,
    required this.url,
  });

  SliderImage.fromJson(final Map<String?, dynamic> json) {
    id = json["id"] ?? '';
    type = (json["type"] == "Category" || json["banner_type"] == "banner_category")
        ? (json['category_parent_id'] == "0")
            ? SliderImagesType.category
            : SliderImagesType.subCategory
        : (json["type"] == "provider" || json["banner_type"] == "banner_provider")
            ? SliderImagesType.provider
            : (json["type"] == "url" || json["banner_type"] == "banner_url")
                ? SliderImagesType.url
                : SliderImagesType.defaultType;
    typeId = json["type_id"] ?? '';
    sliderImage = json["slider_app_image"] ?? json['app_banner_image'];
    categoryName = json["category_name"] ?? '';
    providerName = json["provider_name"] ?? '';
    url = json["url"] ?? json["banner_url"] ?? '';
  }

  String? id;
  SliderImagesType? type;
  String? typeId;
  String? sliderImage;
  String? categoryName;
  String? providerName;
  String? url;
}

enum SliderImagesType {
  category,
  subCategory,
  provider,
  url,
  defaultType,
}
