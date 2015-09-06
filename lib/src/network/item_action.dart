part of couclient;

class SkillRequirements {
	Map<String,int> requiredSkillLevels = {};
}
class ItemRequirements {
	List<String> any = [];
	Map<String, int> all = {};
}
class Action {
	String name;
	String description;
	int timeRequired;
	ItemRequirements itemRequirements = new ItemRequirements();
	SkillRequirements skillRequirements = new SkillRequirements();

	Action();
	Action.withName(this.name);

	@override
	String toString() {
		String returnString = "$name requires any of ${itemRequirements.any}, all of ${itemRequirements.all} and at least ";
		skillRequirements.requiredSkillLevels.forEach((String skill, int level) {
			returnString += "$level level of $skill, ";
		});
		returnString = returnString.substring(0,returnString.length-1);

		return returnString;
	}
}

Future<List<Map>> getItems() async {
	// YYYY-MM-DD
	String today = new DateTime.now().toString().split(" ")[0];

	if (
	localStorage["item_cache_date"] != null && // Date set
	!DateTime.parse(localStorage["item_cache_date"]).isAfter(DateTime.parse(today)) && // Under 24 hours old
	localStorage["item_cache"] != null // Items set
	) {
		// If the cache is fresh
		return JSON.decode(localStorage["item_cache"]);
	} else {
		// Download item data
		String newJSON = await HttpRequest.getString("http://${Configs.utilServerAddress}/getItems");
		// Store item data
		localStorage["item_cache"] = newJSON;
		localStorage["item_cache_date"] = today;
		// Return item data
		print(localStorage["item_cache_date"]);
		return JSON.decode(newJSON);
	}
}

bool isItem({String itemType, String itemName}) {
	if (itemType != null) {
		List<Map> items = JSON.decode(localStorage["item_cache"]);
		return (items.where((Map item) => item["itemType"] == itemType).toList().length > 0);
	}

	if (itemName != null) {
		List<Map> items = JSON.decode(localStorage["item_cache"]);
		return (items.where((Map item) => item["name"] == itemName).toList().length > 0);
	}

	return false;
}

String itemName(String itemType) {
	List<Map> items = JSON.decode(localStorage["item_cache"]);
	return items.where((Map item) => item["itemType"] == itemType).toList().first["name"];
}