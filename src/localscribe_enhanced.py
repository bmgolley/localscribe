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

from roster import ModelWeapon, WeaponProfile


__all__ = (
    'create_filter',
    'create_json',
    'download',
    'run_server',
    'validate_code',
    'AUTOSAVE'
)

import functools
import json
import re
import socketserver
import string
import urllib.parse
import urllib.request
from collections import Counter
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler
from itertools import chain
from typing import (
    TYPE_CHECKING, ClassVar, Iterable, Iterator, Literal, Mapping, TypedDict,
    Unpack, cast, overload)
from urllib.error import HTTPError


if TYPE_CHECKING:
    from roster import Model, ModelProfile, Roster, Unit


YS = 'https://yellowscribe.xyz'

AUTOSAVE = '.autosave.lsroster'


ROSTER_REPLACE: tuple[tuple[str, str], ...] = (
    ('\N{NBSP}', ' '),
    # Removes warlord name prefix
    (r'(?<="name": ")(.*?)(\()?WL(?:\s|\))', r'\1\2'),
    # Changes Unit w/ Gear to Unit | Gear
    (r'(?<="name": ")([^"]+?) w/ ([^"]+)(?=")', '\\1 |\N{NBSP}\\2'),
    # Capitalizes psychic in ability names
    (r'(\(|, )psychic\)', r'\1Psychic)'),
    # Capitalizes aura in ability names
    (r'\(aura(?=\)|,)', r'(Aura'),
    # Removes extra space in Anti- weapon ability
    (r'\b([Aa]nti-)\s(?=\w)', r'\1'),
    # Fix missing number for Rapid Fire weapons
    (r'(?<=bilities": ")(.*?Rapid Fire)(?! \d)', r'\1 1'),
    # Remove extranious quote for range of N/A
    (r'"range": "N/A\W"', r'"range": "N/A"'),
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
                    roster, ensure_ascii=False, indent=4).encode()
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
        with open(AUTOSAVE, 'rb') as f:
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
            with open(AUTOSAVE, 'wb') as f:
                f.write(roster)
        except PermissionError:
            pass
    return roster


def download(code: str | int, *, embed_code: bool = False) -> bytes:
    """Download roster from yellowscribe.xyz.

    Args:
        code (str | int): Code provided by Yellowscribe site.
        embed_code (bool, optional): Embed the Yellowscribe code in \
            the returned roster. Defaults to False.

    Raises:
        ValueError: Code has expired or is invalid.

    Returns
        bytes: JSON roster encoded as UTF-8 (default encoding).
    """
    if not validate_code(code):
        raise ValueError('invalid code')
    if isinstance(code, int):
        code = f'{code:08x}'
    params = urllib.parse.urlencode({'id': code})
    url = f'{YS}/get_army_by_id?{params}'
    try:
        with urllib.request.urlopen(url) as r:
            roster: bytes = r.read()
    except HTTPError as e:
        raise ValueError('code has expired or is invalid') from e
    if embed_code:
        roster_json: Roster = json.loads(roster)
        roster_json['code'] = code
        roster = json.dumps(roster_json, ensure_ascii=False, indent=4).encode()
    return roster


def validate_code(code: str | int | None) -> bool:
    """Determine if the provided code could be vaild.

    This does not check if there is currently a roster with this code,
    only if the entry is an 8-character hexidecimal string or a positive
    integer of with 8 or fewer hexidecimal digits.

    Args:
        code (str | int | None): Code to check.

    Raises:
        TypeError: Provided type is not valid.

    Returns:
        bool: If this is a valid Yellowscibe code.
    """
    match code:
        case str() if len(code) != 8:
            return False
        case str():
            try:
                code = int(code, base=16)
            except ValueError:
                return False
            else:
                return 0 <= code <= 0xffff_ffff
        case int():
            return 0 <= code <= 0xffff_ffff
        case None:
            return False
        case _:
            raise TypeError(
                f'{code.__class__.__name__!r} is not a valid code type')


type KeywordFilter = frozenset[frozenset[str]]
type AbilityChanges = Mapping[KeywordFilter, Mapping[str, str]]
type UnitModelWeapon = tuple[str | None, str | None, str]
class LSOptions(TypedDict, total=False):
    uiHeight: str | int
    """UI height in pixels."""
    uiWidth: str | int
    """UI width in pixels."""
    decorativeNames: bool
    """"""
    statsInvFNP: bool
    """Add invulnerable saves and Feel No Pains to the stats line."""
    indentWeaponProfiles: bool
    """Display multi-profile weapons in the tooltip with each profile
    indented under the weapon name.

    This is instead of displaying them as two separate weapons."""
    shortenWeaponAbilities: bool
    """Shorten weapon abilities in tooltips.

    E.g. Rapid Fire 3 becomes RF3, Anti-fly 2+ becomes Af2+"""
    separateAbilities: bool
    """Separate unit abilities and model abilities on the tooltip."""
    showKeywords: Literal['all', 'filtered'] | None
    """Show all or a filtered list or keywords on a unit tooltip."""
    ignoredKeywords: list[str]
    """Keywords to ignore on a unit tooltip."""
    addAbilities: AbilityChanges
    """"""
    replaceAbilities: AbilityChanges
    """"""
    hideAbilities: Mapping[KeywordFilters, Iterable[str]]
    """"""
    modifyWeapons: Mapping[UnitModelWeapon, Mapping[str, str]]
    """"""
    addWeaponsToNames: bool
    defaultWeapons: Mapping[KeywordFilters, Iterable[str]]
    cleanProfiles: bool
    renameModels: Literal['base', 'decorative'] | None


def create_filter(filter_str: str) -> KeywordFilters:
    """_summary_

    Args:
        filter_str (str): _description_

    Returns:
        frozenset[frozenset[str]]: _description_
    """
    keywords = frozenset(
        frozenset(ks for k in fs.split('&') if (ks := k.strip()))
        for f in filter_str.split(',') if (fs := f.strip())
    )
    return keywords


@overload
def create_json(
        roster: bytes,
        *,
        uiHeight: str | int = ...,
        uiWidth: str = ...,
        decorativeNames: bool = ...,
        statsInvFNP: bool = ...,
        indentWeaponProfiles: bool = ...,
        shortenWeaponAbilities: bool = ...,
        separateAbilities: bool = ...,
        showKeywords: Literal['all', 'filtered'] | None = ...,
        ignoredKeywords: list[str] = ...,
        addAbilities: AbilityChanges = ...,
        replaceAbilities: AbilityChanges = ...,
        hideAbilities: Mapping[KeywordFilters, Iterable[str]] = ...,
        modifyWeapons: Mapping[UnitModelWeapon, Mapping[str, str]] = ...,
        addWeaponsToNames: bool = ...,
        defaultWeapons: Mapping[KeywordFilters, Iterable[str]] = ...,
        cleanProfiles: bool = ...,
        renameModels: Literal['base', 'decorative'] | None = ...,
    ) -> Roster:
    """_summary_

    Args:
        roster (bytes): _description_
        uiHeight (str | int, optional): UI height in pixels.
        uiWidth (str, optional): UI width in pixels.
        decorativeNames (bool, optional): _description_. Defaults to ....
        statsInvFNP (bool, optional): Add invulnerable saves and Feel \
            No Pains to the stats line.
        indentWeaponProfiles (bool, optional): Display multi-profile \
            weapons in the tooltip with each profile indented under \
            the weapon name.
        shortenWeaponAbilities (bool, optional): Shorten weapon \
            abilities in tooltips.
        separateAbilities (bool, optional): Separate unit abilities \
            and model abilities on the tooltip.
        showKeywords (Literal['all', 'filtered'] | None, optional): \
            Show all or a filtered list or keywords on a unit tooltip.
        ignoredKeywords (list[str], optional): Keywords to ignore on a \
            unit tooltip.
        addAbilities (AbilityChanges, optional): _description_. Defaults to ....
        replaceAbilities (AbilityChanges, optional): _description_. Defaults to ....
        hideAbilities (Mapping[FilterKeywords, Iterable[str]], optional): _description_. Defaults to ....
        modifyWeapon (Mapping[tuple[str  |  None, str], Mapping[str, str]], optional): _description_. Defaults to ....
        addWeaponsToNames (bool, optional): _description_. Defaults to ....
        cleanProfiles (bool, optional): _description_. Defaults to ....

    Raises:
        ValueError: _description_

    Returns:
        Roster: _description_
    """
@overload
def create_json(roster: bytes, **kwargs: Unpack[LSOptions]) -> Roster: ...
def create_json(roster: bytes, **kwargs: Unpack[LSOptions]) -> Roster:
    roster_str = functools.reduce(
        lambda x, y: re.sub(*y, x), ROSTER_REPLACE, roster.decode())
    # Converts the roster to a dictonary so it can replace the
    # baseScript entry.
    roster_json: Roster = json.loads(roster_str)
    with open(f'{__file__}/../baseScript_enhanced.lua') as f:
        baseScript = f.read()
    roster_json['baseScript'] = baseScript
    if (uiheight := kwargs.get('uiHeight')):
        kwargs['uiHeight'] = str(uiheight)
    if (uiwidth := kwargs.get('uiWidth')):
        kwargs['uiWidth'] = str(uiwidth)
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
    modify_weapons(roster_json, kwargs.pop('modifyWeapons', None))
    default_weapons = kwargs.pop('defaultWeapons', None)
    if kwargs.pop('addWeaponsToNames', None):
        add_weapons_to_names(roster_json, default_weapons)
    if kwargs.pop('cleanProfiles', None):
        clean_profiles(roster_json)
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
            for _ in range(short_list.count('*') - 1):
                short_list.remove('*')
            short_list.sort(key=lambda x: x == '*')
            weapon['shortAbilities'] = ','.join(short_list).replace(' ', '')


def modify_abilities(
        roster: Roster,
        *,
        add: AbilityChanges | None = None,
        replace: AbilityChanges | None = None,
        hide: Mapping[KeywordFilter, Iterable[str]] | None = None
    ) -> None:
    if not any((add, replace, hide)):
        return
    for unit in roster['armyData'].values():
        key = unit_key(unit)
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
        all_abilities: set[str] = set(
            chain.from_iterable(m['abilities'] for m in models))
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
        changes: Mapping[UnitModelWeapon, Mapping[str, str]] | None
    ):

    def update_abilities(key: str, abilities: str) -> str:
        if key not in abilities:
            if key.rpartition(' ')[2].isdecimal():
                key_abl = key.rpartition(' ')[0]
                if key_abl in abilities:
                    abilities_list = [a.strip() for a in abilities.split(',')]
                    for i, abl in enumerate(abilities_list):
                        if abl.startswith(key_abl):
                            abilities_list[i] = key
                            break
                    abilities = ', '.join(abilities_list)
                else:
                    abilities = f'{abilities}, {key}'
            else:
                abilities = f'{abilities}, {key}'
        return abilities

    if not changes:
        return
    for unit in roster['armyData'].values():
        unit_names = get_names(unit)
        weapon_map = {w.casefold(): w for w in unit['weapons']}
        for unit_weapon, weapon_changes in changes.items():
            unit_name, model_name, weapon_name = unit_weapon
            if (
                    (not unit_name or unit_name in unit_names)
                    and (n := weapon_map.get(weapon_name.casefold()))
                    and (profile := unit['weapons'].get(n))
                ):
                try:
                    name = next(
                        v for k, v in weapon_changes.items()
                        if k.casefold() == 'name'
                    )
                except StopIteration:
                    name = None
                # if model_name:
                #     found = False
                #     for model in unit['models']['models'].values():
                #         if model['name'] == model_name:
                #             for weapon in model['weapons']:
                #                 if (
                #                         weapon['name'].casefold()
                #                         == weapon_name.casefold()
                #                     ):
                #                     weapon['name'] = name or f'{weapon['name']}*'
                #                     found = True
                #     if not found:
                #         continue
                #     profile = profile.copy()
                #     if not name:
                #         name = f'{profile['name']} ({model_name})'
                #         profile['name'] = name
                #     unit['weapons'][name] = profile
                for key, value in weapon_changes.items():
                    if (cikey := key.casefold()) in ('ws', 'bs'):
                        cikey = 'bsws'
                    if cikey in profile:
                        if not value:
                            print(f'Weapon {unit_name}.{weapon_name} changed property {key} missing value.')
                            continue
                        if cikey == 'name':
                            for model in unit['models']['models'].values():
                                for weapon in model['weapons']:
                                    if weapon['name'] == profile['name']:
                                        weapon['name'] = value
                        elif value.startswith('+'):
                            value = value.removeprefix('+')
                            if key == 'number':
                                value = profile[cikey] + int(value)
                            else:
                                prev: str = profile[cikey]
                                prev_num, prev_size, prev_mod = split_dice_str(
                                    prev)
                                num, size, mod = split_dice_str(value)
                                if size and prev_size and size != prev_size:
                                    print(f'Weapon {unit_name}.{weapon_name} changed property {key} mod value {value} conflicts with current value {prev}')
                                    continue
                                mod += prev_mod
                                if size or (size := prev_size):
                                    num += prev_num
                                    dice = f'{num}D{size}'
                                    value = f'{dice}+{mod}'
                                else:
                                    value = str(mod)
                        profile[cikey] = value
                    else:
                        if (sa := profile['shortAbilities']) == '-':
                            profile['shortAbilities'] = key
                        else:
                            profile['shortAbilities'] = update_abilities(
                                key, sa)
                        mod_ability = f'{key}: {value}'
                        if profile['abilities'] == '-':
                            profile['abilities'] = (
                                f'{key}\n{mod_ability}' if value else key)
                        else:
                            abilities, _, desc_str = (
                                profile['abilities'].partition('\n'))
                            if not value:
                                if key in abilities:
                                    continue
                                else:
                                    abilities = update_abilities(
                                        key, abilities)
                                    if desc_str:
                                        abilities = f'{abilities}\n{desc_str}'
                            elif desc_str:
                                desc = [d.strip() for d in desc_str.split(',')]
                                mod_ability = f'{key}: {value}'
                                abilities = update_abilities(key, abilities)
                                for i, abl in enumerate(desc):
                                    if abl.startswith(f'{key}:'):
                                        desc[i] = mod_ability
                                        break
                                else:
                                    desc.append(mod_ability)
                                abilities = f'{abilities}\n{', '.join(desc)}'
                            else:
                                abilities = update_abilities(key, abilities)
                                abilities = f'{abilities}\n{mod_ability}'
                            profile['abilities'] = abilities


def find_unique_weapons(
        unit: Unit,
        default_weapons: Mapping[KeywordFilter, Iterable[str]] | None = None
    ) -> Iterator[tuple[Model, str]]:
    if not default_weapons:
        default_weapons = {}
    if len(models := list(unit['models']['models'].values())) > 1:
        half = unit['models']['totalNumberOfModels']/2
        key = unit_key(unit)
        unit_defaults = set(
            chain.from_iterable(
                (w.casefold() for w in weapons)
                for filters, weapons in default_weapons.items()
                if not filters or any(k <= key for k in filters)
            )
        )
        if models[0]['number'] == 1:
            del models[0]
        count = Counter(
            chain.from_iterable(
                (weapon_base_name(weapon),)*model['number']
                for model in models for weapon in model['weapons'])
        )
        model_weapons = tuple(
            (
                model,
                set(
                    name for weapon in model['weapons']
                    if (name := weapon_base_name(weapon)).casefold()
                        not in unit_defaults
                    and count[name] < half
                ),
            ) for model in models
            if ' |\N{NBSP}' not in model['name']
        )
        unique = (
            (model, next(iter(weapons)))
            for model, weapons in model_weapons if len(weapons) == 1
        )
        for model, weapons in model_weapons:
            if len(weapons) > 1:
                print(unit['name'], model['name'], weapons)
    else:
        unique = iter(())
    return unique


def add_weapons_to_names(
        roster: Roster,
        default_weapons: Mapping[KeywordFilter, Iterable[str]] | None = None
    ) -> None:

    if not default_weapons:
        default_weapons = {}
    for unit in roster['armyData'].values():
        for model, weapon in find_unique_weapons(unit, default_weapons):
            model['name'] = f'{model['name']} |\N{NBSP}{weapon}'
        for model in unit['models']['models'].values():
            name, _, gear = model['name'].partition(' |\N{NBSP}')
            if gear:
                model['name'] = f'{name} |\N{NBSP}{string.capwords(gear)}'


def get_names(source: Unit | ModelProfile) -> set[str]:
    names = {source['name']}
    if (name_m := re.match(r'(.+)\s\((.+)\)$', source['name'])):
        names.update(name_m.groups())
    return names


def unit_key(unit: Unit) -> set[str]:
    key = get_names(unit).union(unit['factionKeywords'], unit['keywords'])
    return key


def split_dice_str(value: str):
    if '+' in value:
        dice, _, mod = value.partition('+')
    elif 'D' in value:
        dice, mod = value, 0
    else:
        dice, mod = '', value
    num, _, size = dice.partition('D')
    if not num:
        num = 0
    if not size:
        size = 0
    return int(num), int(size), int(mod)


def weapon_base_name(weapon: ModelWeapon | WeaponProfile) -> str:
    return weapon['name'].partition(' - ')[0].strip()


def model_base_name(model: Model | ModelProfile) -> str:
    return (
        model['name'].partition('w/')[0].partition('|')[0].partition('(')[0]
        .strip()
    )


def clean_profiles(roster: Roster) -> None:
    """Remove duplicate model profiles.

    Remove duplicate model profiles where the only difference is wargear
    appended to the model name.

    Args:
        roster (Roster): Localscribe roster.
    """
    for unit in roster['armyData'].values():
        if len(profiles := tuple(unit['modelProfiles'])) > 1:
            for profile in profiles:
                if (
                        (base := profile.rpartition(' w/ ')[0])
                        and (base_profile := unit['modelProfiles'].get(base))
                        and base_profile is not unit['modelProfiles'][profile]
                        and all(
                            unit['modelProfiles'][profile][k] == v
                            for k, v in base_profile.items() if k != 'name'
                        )
                    ):
                    del unit['modelProfiles'][profile]


def rename_models(
        roster: Roster, naming: Literal['base', 'decorative'] | None) -> None:
    def _rename_base(name: str) -> str:
        name = ' '.join(
            (name.partition('(')[0].strip(), name.rpartition(')')[1].strip()))
        return name

    def _rename_decorative(name: str) -> str:
        name = re.sub(r'^.+?\s+\((.+)\)(.*)', r'\1\2', name)
        return name

    if not naming:
        return
    elif naming == 'base':
        rename = _rename_base
    else:
        rename = _rename_decorative
    for unit in roster['armyData'].values():
        for model in unit['models']['models'].values():
            model['name'] = rename(model['name'])
        if naming == 'base':
            for profile in unit['modelProfiles'].values():
                profile['name'] = rename(profile['name'])



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

    roster = get_roster(code)
    roster_json = create_json(roster, **vars(args))
    try:
        # Start server.
        run_server(roster_json)
    except KeyboardInterrupt:
        # Exit on ctrl-c.
        print('Shutting down server.')
