import json
from context import localscribe_enhanced as lse


with open(f'{__file__}/../../.autosave.lsroster', 'rb') as f:
    roster = f.read()

roster_json = lse.create_json(roster)
lse.clean_profiles(roster_json)
lse.add_weapons_to_names(roster_json)
with open(f'{__file__}/../apply_all.json', 'w', encoding='utf-8') as f:
    json.dump(roster_json, f, ensure_ascii=False, indent=4)
