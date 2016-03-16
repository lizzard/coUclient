part of couclient;

abstract class Skills {
	static List<Map<String, dynamic>> data;

	static Future loadData() async {
		data = JSON.decode(await HttpRequest.getString(
			"http://${Configs.utilServerAddress}/skills/get/${game.email}"
		));
	}

	static Map<String, dynamic> getSkill(String id) {
		List<Map<String, dynamic>> skills = data.where((Map skill) {
			return skill["id"] == id;
		}).toList();

		return (skills.length > 0 ? skills.single : null);
	}
}

class SkillIndicator {
	Map skill;
	Element parent, fill;

	SkillIndicator(String skillId) {
		Skills.loadData().then((_) {
			skill = Skills.getSkill(skillId);

			if (skill != null) {
				// Prepare

				fill = new DivElement()
					..classes = ["skillindicator-fill"]
					..style.height = "${(skill["player_points"] / skill["player_nextPoints"]) * 100}%"
					..style.backgroundImage = "url(${skill["player_iconUrl"]})";

				parent = new DivElement()
					..classes = ["skillindicator-parent"]
					..append(fill);

				CurrentPlayer.superParentElement.append(parent);

				// Position

				Rectangle outlineRect = parent.client;
				int outlineWidth = outlineRect.width;
				int outlineHeight = outlineRect.height;
				num playerX = num.parse(CurrentPlayer.playerParentElement.attributes['translatex']);
				num playerY = num.parse(CurrentPlayer.playerParentElement.attributes['translatey']);
				int x = playerX ~/ 1 - outlineWidth ~/ 2 - CurrentPlayer.width ~/ 3;
				int y = playerY ~/ 1 + outlineHeight - 45;

				parent.style
					..left = "${x}px"
					..top = "${y}px";
			}
		});
	}

	void close() {
		parent?.remove();
	}
}