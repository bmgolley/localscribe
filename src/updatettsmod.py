import json
from pathlib import Path
from typing import TYPE_CHECKING


if TYPE_CHECKING:
    from ttsmod import TTSMod


saves_dir = Path(
    '~/OneDrive/Documents/My Games/Tabletop Simulator/Saves'
).expanduser()


def update():
    with open(saves_dir/'40k/LocalscribeEnhanced.json') as f:
        localscribe: TTSMod = json.load(f)
    with open(f'{__file__}/../Yellow Machine.lua') as f:
        script = f.read()
    try:
        ym = next(
            obj for obj in localscribe['ObjectStates']
            if obj['Nickname'] == 'Yellow Machine'
        )
    except StopIteration:
        raise ValueError("'Yellow Machine' object is missing")
    ym['LuaScript'] = script
    with open(saves_dir/'40k/LocalscribeEnhanced.json', 'w') as wf:
        json.dump(localscribe, wf, ensure_ascii=False, indent=4)

update()
