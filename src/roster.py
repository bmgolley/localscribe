from __future__ import annotations

from typing import NotRequired, TypedDict


class Roster(TypedDict):
    edition: str
    order: list[str]
    armyData: dict[str, Unit]
    uiHeight: str
    uiWidth: str
    decorativeNames: str | bool
    baseScript: str
    showKeywords: NotRequired[str]
    ignoredKeywords: NotRequired[list[str]]
    shortenWeaponAbilities: NotRequired[bool]
    code: NotRequired[str]


class Unit(TypedDict):
    name: str
    factionKeywords: list[str]
    keywords: str
    abilities: dict[str, Ability]
    models: Models
    modelProfiles: dict[str, ModelProfile]
    weapons: dict[str, WeaponProfile]
    isSingleModel: bool
    uuid: str
    rules: list
    unassignedWeapons: list
    unitAbilities: NotRequired[list[str]]


class Ability(TypedDict):
    name: str
    desc: str


class Models(TypedDict):
    models: dict[str, Model]
    totalNumberOfModels: int


class Model(TypedDict):
    name: str
    abilities: list[str]
    weapons: list[ModelWeapon]
    number: str
    modelAbilities: NotRequired[list[str]]


class ModelProfile(TypedDict):
    name: str
    m: str
    t: str
    sv: str
    w: str
    ld: str
    oc: str


class WeaponProfile(TypedDict):
    name: str
    range: str
    a: str
    bsws: str
    s: str
    ap: str
    d: str
    number: int
    abilities: str
    shortAbilities: str


class ModelWeapon(TypedDict):
    name: str
    number: str
