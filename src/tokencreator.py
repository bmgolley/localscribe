import json
from pathlib import Path
from typing import TYPE_CHECKING


if TYPE_CHECKING:
    from ttsmod import TTSMod


saves_dir = Path(
    '~/OneDrive/Documents/My Games/Tabletop Simulator/Saves/Saved Objects'
).expanduser()

def update():
    with open(f'{__file__}/../Token Creator.json') as modfile:
        mod: TTSMod = json.load(modfile)
    with open(f'{__file__}/../Token Creator.lua') as scriptfile:
        script = scriptfile.read()
    mod['ObjectStates'][0]['LuaScript'] = script
    with open(f'{__file__}/../Token Creator.json', 'w') as modfile:
        json.dump(mod, modfile, ensure_ascii=False, indent=4)


def deploy():
    with (
            open(f'{__file__}/../Token Creator.json') as source,
            saves_dir.joinpath('40k/Token Creator.json').open('w') as target
        ):
        target.write(source.read())

update()
deploy()