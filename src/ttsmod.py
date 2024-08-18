from __future__ import annotations


__all__ = ('TTSMod',)

from typing import NotRequired, TypedDict


class TTSMod(TypedDict):
    SaveName: str
    EpochTime: int
    Date: str
    VersionNumber: str
    GameMode: str
    GameType: str
    GameComplexity: str
    Tags: list
    Gravity: int
    PlayArea: int
    Table: str
    Sky: str
    SkyURL: str
    Note: str
    TabStates: dict[str, TabState]
    MusicPlayer: NotRequired[MusicPlayer]
    Grid: Grid
    Lighting: Lighting
    Hands: Hands
    ComponentTags: ComponentTags
    Turns: Turns
    CameraStates: NotRequired[list[CameraState | None]]
    DecalPallet: list
    LuaScript: str
    LuaScriptState: str
    XmlUI: str
    ObjectStates: list[ObjectState]


class TabState(TypedDict):
    title: str
    body: str
    color: str
    visibleColor: Color
    id: int


class MusicPlayer(TypedDict):
    RepeatSong: bool
    PlaylistEntry: int
    CurrentAudioTitle: str
    CurrentAudioURL: str
    AudioLibrary: list[dict[str, str]]


class Grid(TypedDict):
    Type: int
    Lines: bool
    Color: Color
    Opacity: float
    ThickLines: bool
    Snapping: bool
    Offset: bool
    BothSnapping: bool
    xSize: float
    ySize: float
    PosOffset: Vector


class Lighting(TypedDict):
    LightIntensity: float
    LightColor: Color
    AmbientIntensity: float
    AmbientType: int
    AmbientSkyColor: Color
    AmbientEquatorColor: Color
    AmbientGroundColor: Color
    ReflectionIntensity: float
    LutIndex: int
    LutContribution: float
    LutURL: str


class Hands(TypedDict):
    Enable: bool
    DisableUnused: bool
    Hiding: int


class ComponentTags(TypedDict):
    labels: list[Label]
    normalized: NotRequired[str]


class Label(TypedDict):
    displayed: str


class Turns(TypedDict):
    Enable: bool
    Type: int
    TurnOrder: list
    Reverse: bool
    SkipEmpty: bool
    DisableInteractions: bool
    PassTurns: bool
    TurnColor: str


class CameraState(TypedDict):
    Position: Vector
    Rotation: Vector
    Distance: float
    Zoomed: bool
    AbsolutePosition: Vector


class ObjectState(TypedDict):
    GUID: str
    name: str
    Transform: Transform
    Nickname: str
    Description: str
    GMNotes: str
    AltLookAngle: Vector
    ColorDiffuse: Color
    LayoutGroupSortIndex: int
    Value: int
    Locked: bool
    Grid: bool
    Snap: bool
    IgnoreFoW: bool
    MeasureMovement: bool
    DragSelectable: bool
    Autoraise: bool
    Sticky: bool
    Tooltip: bool
    GridProjection: bool
    HideWhenFaceDown: bool
    Hands: bool
    FogColor: NotRequired[str]
    MaterialIndex: NotRequired[int]
    MeshIndex: NotRequired[int]
    Number: NotRequired[int]
    CustomAssetbundle: NotRequired[CustomAssetbundle]
    CustomImage: NotRequired[CustomImage]
    CustomMesh: NotRequired[CustomMesh]
    Bag: NotRequired[Bag]
    Text: NotRequired[Text]
    LuaScript: str
    LuaScriptState: str
    XmlUI: str
    States: NotRequired[dict[str, ObjectState]]


class Transform(TypedDict):
    posX: float
    posY: float
    posZ: float
    rotX: float
    rotY: float
    rotZ: float
    scaleX: float
    scaleY: float
    scaleZ: float


class CustomAssetbundle(TypedDict):
    AssetbundleURL: str
    AssetbundleSecondaryURL: str
    MaterialIndex: int
    TypeIndex: int
    LoopingEffectIndex: int


class CustomImage(TypedDict):
    ImageURL: str
    ImageSecondaryURL: str
    ImageScalar: float
    WidthScale: float
    CustomTile: CustomTile


class CustomTile(TypedDict):
    Type: int
    Thickness: float
    Stackable: bool
    Stretch: bool


class CustomMesh(TypedDict):
    MeshURL: str
    DiffuseURL: str
    NormalURL: str
    ColliderURL: str
    Convex: bool
    MaterialIndex: int
    TypeIndex: int
    CustomShader: NotRequired[CustomShader]
    CastShadows: bool


class CustomShader(TypedDict):
    SpecularColor: Color
    SpecularIntensity: float
    SpecularSharpness: float
    FresnelStrength: float


class Bag(TypedDict):
    Order: int


class Text(TypedDict):
    Text: str
    colorState: Color
    fontSize: int


class Color(TypedDict):
    r: float
    g: float
    b: float


class Vector(TypedDict):
    x: float
    y: float
    z: float
