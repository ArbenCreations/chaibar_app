import '../../model/response/productListResponse.dart';

class AddOnBuildResult {
  final List<AddOnCategory> categories;
  final List<String> ids;
  final String type;

  AddOnBuildResult({
    required this.categories,
    required this.ids,
    required this.type,
  });
}

AddOnBuildResult buildSelectedAddOns({required List<AddOnCategory> addOns}) {
  List<AddOnCategory> addOnCategories = [];
  List<String> selectedAddOnIdList = [];
  String addOnType = "";

  for (var item in addOns) {
    List<AddOnDetails> selectedAddOns = [];

    if (item.addOnCategoryType == "multiple") {
      for (var addOn in item.addOns ?? []) {
        if (addOn.isSelected) {
          selectedAddOns.add(addOn);
          selectedAddOnIdList.add(addOn.id.toString());
        }
      }
      addOnType = "multiple";
    } else {
      for (var addOn in item.addOns ?? []) {
        if (item.selectedAddOnIdInSingleType == addOn.id) {
          selectedAddOns.add(addOn);
          selectedAddOnIdList.add(addOn.id.toString());
        }
      }
      addOnType = "single";
    }

    if (selectedAddOns.isNotEmpty) {
      addOnCategories.add(AddOnCategory(
        addOnCategory: item.addOnCategory,
        addOnCategoryType: item.addOnCategoryType,
        addOns: selectedAddOns,
      ));
    }
  }

  return AddOnBuildResult(
    categories: addOnCategories,
    ids: selectedAddOnIdList,
    type: addOnType,
  );
}
