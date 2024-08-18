#! /usr/bin/env python3
"""Command-line tool to download a roster from Yellowscribe.xyz and
serve locally.

This will run indefinitly rather than expiring after 10 minutes.

usage: localscribe_enhanced.py [-h] [-uih UIHEIGHT] [-uiw UIWIDTH]
    [-d {True,False}] [-a] [code]

positional arguments:
    code                    army code from yellowscribe.xyx

options:
    -uih, --uiheight        override UI height
    -uiw, --uiwidth         override UI width
    -d, --decorativenames   override decorative names
    -a, --shortenabilities  shorten full weapon abilities
    -h, --help              show this help message and exit
"""
from __future__ import annotations

from collections.abc import Iterable, Mapping
import functools
import json
import re
import socketserver
import urllib.parse
import urllib.request
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler
from typing import (
    TYPE_CHECKING, Callable, ClassVar, Literal, TypedDict, Unpack, cast)
from urllib.error import HTTPError


if TYPE_CHECKING:
    from roster import Roster


YS = 'https://yellowscribe.xyz'


ROSTER_REPLACE: tuple[tuple[re.Pattern[str], str | Callable[[re.Match]]], ...] = (
    (re.compile('\N{NBSP}'), ' '),
    # Removes warlord name prefix
    (re.compile(r'(?<="name": ")(.*?)(\()?WL(?:\s|\))'), r'\1\2'),
    # Changes Unit w/ Gear to Unit | Gear
    (re.compile(r'(?<="name": ")([^"]+?) w/ ([^"]+)(?=")'), fr'\1 |{chr(0xa0)}\2'),
    # Capitalizes psychic in ability names
    (re.compile(r'(\(|, )psychic\)'), r'\1Psychic)'),
    # Capitalizes aura in ability names
    (re.compile(r'\(aura(?=\)|,)'), r'(Aura'),
    # Removes extra space in Anti- weapon ability
    (re.compile(r'\b([Aa]nti-)\s(?=\w)'), r'\1'),
    # Fix missing number for Rapid Fire weapons
    (re.compile(r'(?<=bilities": ")(.*?Rapid Fire)(?! \d)'), r'\1 1')
)
"""Tuple of string replacements"""


ABILITY_MAP = {
    'Assault': 'AS',
    'Blast': 'BL',
    'Devastating Wounds': 'DW',
    'Extra Attacks': 'EA',
    'Hazardous': 'HZ',
    'Heavy': 'HV',
    'Ignores Cover': 'IC',
    'Indirect Fire': 'IF',
    'Lance': 'LA',
    'Lethal Hits': 'LH',
    'Melta': 'ML',
    'One Shot': 'OS',
    'Pistol': 'PL',
    'Precision': 'PR',
    'Rapid Fire': 'RF',
    'Sustained Hits': 'SH',
    'Torrent': 'TO',
    'Twin-Linked': 'TL',
    '-': '-'
}

WEAPON_P = re.compile(r'([A-Z][A-Za-z\s\-]+)(\s\d\+?|$)?')


class TTSHandler(BaseHTTPRequestHandler):
    """HTTP Request Handler that provides a roster to TTS."""

    _roster: ClassVar[bytes]
    """JSON roster encoded as UTF-8 (default encoding)."""

    @classmethod
    def factory(cls, roster: bytes | str | Roster):
        """Create an HTTP Request Handler for the provided roster.

        TCPServer requires a handler type, not an instance. This creates
        a new type with the roster data set.

        Args:
            roster (bytes | str | dict): JSON roster encoded as UTF-8 \
                (default encoding), as a string, or as a dict
        Returns:
            type[TTSHandler]: new TTSHandler type
        """
        handler_cls = type('Handler', (cls,), {})
        match roster:
            case bytes():
                handler_cls._roster = roster
            case str():
                handler_cls._roster = roster.encode()
            case dict():
                handler_cls._roster = json.dumps(
                    roster, ensure_ascii=False).encode()
            case _:
                raise TypeError
        return handler_cls

    def do_GET(self) -> None:
        """Provide the roster data.

        Handle GET requests.
        """
        self.send_response(HTTPStatus.OK)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(self._roster)


def get_roster(code: str | None = None) -> bytes:
    try:
        if code:
            roster = download(code)
        else:
            raise ValueError
    except ValueError:
        # If no code or an invalid code is provided, use a backup of
        # the last successful download.
        with open('roster.bin', 'rb') as f:
            roster = f.read()
        if code:
            print(
                'Download unsuccessful, loading saved data and starting'
                ' server.'
            )
        else:
            print('No code provided, loading saved data and starting server.')
    else:
        print('Download successful, starting server.')
        # Backup downloaded data.
        try:
            with open('roster.bin', 'wb') as f:
                f.write(roster)
        except PermissionError:
            pass
    return roster


def download(code: str) -> bytes:
    """Download roster from yellowscribe.xyz.

    Args:
        code (str): code provided by Yellowscribe site
    Raises:
        ValueError: code has expired or is invalid
    Returns
        bytes: JSON roster encoded as UTF-8 (default encoding)
    """
    if not code or not re.fullmatch(r'[\dA-Fa-f]{8}', code):
        raise ValueError('invalid code')
    params = urllib.parse.urlencode({'id': code})
    url = f'{YS}/get_army_by_id?{params}'
    try:
        with urllib.request.urlopen(url) as r:
            roster: bytes = r.read()
    except HTTPError as e:
        raise ValueError('code has expired or is invalid') from e
    return roster


type FilterKeywords = frozenset[frozenset[str]]
type AbilityChanges = Mapping[FilterKeywords, Mapping[str, str]]
class LSOptions(TypedDict, total=False):
    uiHeight: str
    uiWidth: str
    decorativeNames: bool
    statsInvFNP: bool
    indentWeaponProfiles: bool
    shortenWeaponAbilities: bool
    separateAbilities: bool
    showKeywords: Literal['all', 'filtered'] | None
    ignoredKeywords: list[str]
    addAbilities: AbilityChanges
    replaceAbilities: AbilityChanges
    hideAbilities: Mapping[FilterKeywords, Iterable[str]]
    addWeaponAbilities: Mapping[tuple[str | None, str], Mapping[str, str]]


def create_filter(filter_str: str) -> frozenset[frozenset[str]]:
    keywords = frozenset(
        frozenset(ks for k in fs.split('+') if (ks := k.strip()))
        for f in filter_str.strip().split(',') if (fs := f.strip())
    )
    return keywords


def create_json(roster: bytes, **kwargs: Unpack[LSOptions]) -> Roster:
    roster_str = functools.reduce(
        lambda x, y: re.sub(*y, x), ROSTER_REPLACE, roster.decode())
    # Converts the roster to a dictonary so it can replace the
    # baseScript entry.
    roster_json: Roster = json.loads(roster_str)
    with open(f'{__file__}/../baseScript_enhanced.lua') as f:
        baseScript = f.read()
    roster_json['baseScript'] = baseScript
    roster_json['decorativeNames'] = kwargs.pop(
        'decorativeNames', roster_json['decorativeNames'] == 'true')
    if kwargs.get('shortenWeaponAbilities'):
        shorten_weapon_abilities(roster_json)
    if kwargs.get('separateAbilities'):
        separate_abilities(roster_json)
    modify_abilities(
        roster_json,
        add=kwargs.pop('addAbilities', None),
        replace=kwargs.pop('replaceAbilities', None),
        hide=kwargs.pop('hideAbilities', None)
    )
    modify_weapons(roster_json, kwargs.pop('addWeaponAbilities'))
    roster_json.update(kwargs)  # pyright: ignore[reportArgumentType,reportCallIssue]
    return roster_json


def shorten_weapon_abilities(roster: Roster) -> None:
    def format_ability(m: re.Match[str]):
        string_1, string_2 = cast(tuple[str, str | None], m.groups())
        if string_1.startswith('Anti-'):
            string_1 = f'A{string_1.removeprefix('Anti-').strip()[0].lower()}'
        else:
            string_1 = ABILITY_MAP.get(string_1.title(), '*')
        if string_2:
            string = f'{string_1}{string_2.strip()}'
        else:
            string = string_1
        return string

    for unit in roster['armyData'].values():
        for weapon in  unit['weapons'].values():
            abilities, short = weapon['abilities'], weapon['shortAbilities']
            if abilities == short == '-':
                continue
            if '-' in (abilities, short):
                raise ValueError(
                    f"conflict in abilities for weapon '{weapon['name']}'")
            short_list = [
                format_ability(ab)
                for a in abilities.partition('\n')[0].split(',')
                if (ab := WEAPON_P.fullmatch(a.strip()))
            ]
            if (n := short_list.count('*')) > 1:
                for _ in range(n- 1):
                    short_list.remove('*')
            short_list.sort(key=lambda x: x == '*')
            weapon['shortAbilities'] = ','.join(short_list).replace(' ', '')


def modify_abilities(
        roster: Roster,
        *,
        add: AbilityChanges | None = None,
        replace: AbilityChanges | None = None,
        hide: Mapping[FilterKeywords, Iterable[str]] | None = None
    ) -> None:
    if not any((add, replace, hide)):
        return
    for unit in roster['armyData'].values():
        unit_name = re.sub(
            r'.*\((.*)\)$', lambda m: m[1] if m[1] else m[0], unit['name'])
        key = set(unit['factionKeywords']).union(
            unit['keywords'], {unit['name'], unit_name})
        if add:
            for add_key, add_abilities in add.items():
                if not add_key or any(k <= key for k in add_key):
                    unit['abilities'].update({
                        n: {'name': n, 'desc': d}
                        for n, d in add_abilities.items()
                        if n not in unit['abilities']
                    })
                    if (unit_abilites := unit.get('unitAbilities')):
                        unit_abilites.extend(
                            a for a in add_abilities if a not in unit_abilites)
                    for model in unit['models']['models'].values():
                        model['abilities'].extend(
                            a for a in add_abilities
                            if a not in model['abilities']
                        )
        if replace:
            for replace_key, replace_abilities in replace.items():
                if not replace_key or any(k <= key for k in replace_key):
                    for name, desc in replace_abilities.items():
                        try:
                            unit['abilities'][name]['desc'] = desc
                        except KeyError:
                            pass
        if hide:
            for hide_key, hide_abilities in hide.items():
                if not hide_key or any(k <= key for k in hide_key):
                    if (unit_abilites := unit.get('unitAbilities')):
                        for ability in hide_abilities:
                            while ability in unit_abilites:
                                unit_abilites.remove(ability)
                    for model in unit['models']['models'].values():
                        for ability in hide_abilities:
                            while ability in model['abilities']:
                                model['abilities'].remove(ability)
                            if (model_abilities := model.get('modelAbilities')):
                                while ability in model_abilities:
                                    model_abilities.remove(ability)


def separate_abilities(roster: Roster) -> None:
    for unit in roster['armyData'].values():
        models = unit['models']['models'].values()
        if len(models) == 1:
            model = next(iter(models))
            unit['unitAbilities'] = model['abilities']
            model['modelAbilities'] = []
            continue
        abilities = list(unit['abilities'])
        all_abilities: set[str] = set.union(
            *(set(m['abilities']) for m in models))
        try:
            core_abilities = unit['abilities']['Core']['desc'].split(', ')
        except KeyError:
            core_abilities = []
        else:
            for i, ability in enumerate(reversed(core_abilities), 1):
                if ability.startswith('Damaged:'):
                    del core_abilities[-i]
        unit_abilities: set[str] = set.intersection(
            *(set(m['abilities']) for m in models))
        model_abilities: set[str] = all_abilities - unit_abilities
        def key(s: str):
            try:
                return core_abilities.index(s)
            except ValueError:
                try:
                    return len(core_abilities) + abilities.index(s)
                except ValueError:
                    return len(core_abilities) + len(abilities)
        unit['unitAbilities'] = sorted(
            unit_abilities - model_abilities, key=key)
        for model in models:
            model['modelAbilities'] = sorted(
                set(model['abilities']) - unit_abilities,
                key=model['abilities'].index
            )


def modify_weapons(
        roster: Roster,
        changes: Mapping[tuple[str | None, str], Mapping[str, str]]
    ):
    for unit in roster['armyData'].values():
        # unit_name = re.sub(
        #     r'.*\((.*)\)$', lambda m: m[1] if m[1] else m[0], unit['name'])
        unit_names = {unit['name']}
        if (names := re.match(r'(.*)\s\((.*)\)$', unit['name'])):
            unit_names.update(names.groups())
        for unit_weapon, weapon_changes in changes.items():
            if (
                    (not unit_weapon[0] or unit_weapon[0] in unit_names)
                    and (profile := unit['weapons'].get(unit_weapon[1]))
                ):
                for key, value in weapon_changes.items():
                    if key in profile:
                        if not value:
                            print(f'Weapon {unit_weapon[0]}.{unit_weapon[1]} changed property {key} missing value.')
                            continue
                        profile[key] = value
                    else:
                        if key not in (sa := profile['shortAbilities']):
                            sa = f'{sa}, {key}' if sa != '-' else key
                            profile['shortAbilities'] = sa
                        mod_ability = f'{key}: {value}'
                        if profile['abilities'] == '-':
                            profile['abilities'] = (
                                mod_ability if value else key)
                        else:
                            abilities, _, desc_str = (
                                profile['abilities'].partition('\n'))
                            if not value:
                                if key in abilities:
                                    continue
                                else:
                                    abilities = f'{abilities}, {key}'
                            elif desc_str:
                                desc = [d.strip() for d in desc_str.split(',')]
                                mod_ability = f'{key}: {value}'
                                if key not in abilities:
                                    abilities = f'{abilities}, {key}'
                                for i, abl in enumerate(desc):
                                    if abl.startswith(f'{key}:'):
                                        desc[i] = mod_ability
                                        break
                                    else:
                                        desc.append(mod_ability)
                                abilities = (
                                    f'{', '.join(abilities)}\n{', '.join(desc)}')
                            else:
                                if key not in abilities:
                                    abilities = f'{abilities}, {key}'
                                abilities = f'{abilities}\n{mod_ability}'
                            profile['abilities'] = abilities


def run_server(roster: bytes | str | Roster) -> None:
    """Start the local server.

    Will run until program is exited.

    Args:
        roster (bytes | str | dict): JSON roster encoded as UTF-8 \
            (default encoding)
    """
    with socketserver.TCPServer(
            ('', 40_000), TTSHandler.factory(roster)) as server:
        server.serve_forever()


if __name__ == '__main__':
    import argparse

    # Create an argument parser instance and define 'code' argument.
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'code', nargs='?', help='army code from yellowscribe.xyx')
    parser.add_argument(
        '-uih', '--uiHeight', type=int, help='override UI height')
    parser.add_argument(
        '-uiw', '--uiWidth', type=int, help='override UI width')
    parser.add_argument(
        '-d', '--decorativenames', choices=(True, False),
        help='override decorative names'
    )
    parser.add_argument(
        '-a', '--shortenWeaponAbilities', action='store_true',
        help='shorten full weapon abilities'
    )
    parser.add_argument(
        '-k', '--showKeywords', nargs='?', choices=('all', 'filtered', None),
        const='filtered', help='show keywords in unit tooltip'
    )

    # Parse command-line arguments and extract army code.
    args = parser.parse_args()
    code: str = args.code

    # Download roster using provided code.
    # try:
    #     roster = download(code)
    # except ValueError:
    #     # If no code or an invalid code is provided, use a backup of
    #     # the last successful download.
    #     with open('roster.bin', 'rb') as f:
    #         roster = f.read()
    #     if code:
    #         print(
    #             'Download unsuccessful, loading saved data and starting'
    #             ' server.'
    #         )
    #     else:
    #         print('No code provided, loading saved data and starting server.')
    # else:
    #     print('Download successful, starting server.')
    #     # Backup downloaded data.
    #     try:
    #         with open('roster.bin', 'wb') as f:
    #             f.write(roster)
    #     except PermissionError:
    #         pass

    roster = get_roster(code)
    roster_json = create_json(roster, **vars(args))
    try:
        # Start server.
        run_server(roster_json)
    except KeyboardInterrupt:
        # Exit on ctrl-c.
        print('Shutting down server.')
