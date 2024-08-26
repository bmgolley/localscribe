from __future__ import annotations


__all__ = ('LocalscribeGUI', 'validate_filepath')

import atexit
import json
import multiprocessing
import tkinter
import traceback
from configparser import ConfigParser
from fnmatch import fnmatch
from pathlib import Path
from tkinter import constants as tkc
from tkinter import filedialog as tkfiledialog
from tkinter import ttk
from typing import TYPE_CHECKING, Any, Literal, override

import localscribe_enhanced as lse


if TYPE_CHECKING:
    from _typeshed import StrPath

    from roster import Roster


HORZ = tkc.E + tkc.W
"""Stretch horizontally."""
VERT = tkc.N + tkc.S
"""Stretch Vertically."""
FILL = HORZ + VERT
"""Stretch to fill the availible space."""

BOOL_KEYS = (
    'stats_inv_fnp', 'indent_weapon_profiles', 'shorten_abilites',
    'separate_abilities', 'add_weapons_to_names',
    'clean_profiles',
)

CONFIG_KEYS = BOOL_KEYS + ('show_keywords',)

AUTOSAVE = Path(lse.AUTOSAVE)

FILE_DIALOG_KWARGS = {
    'defaultextension': '.lsroster',
    'filetypes': (('Localscribe Roster', '.lsroster'), ('JSON File', '.json'))
}


class LocalscribeGUI(ttk.Frame):
    master: tkinter.Tk
    _status_msg_widget: tkinter.Message | None
    _filepath: Path | None
    _server: multiprocessing.Process
    """Running server process."""
    _run_btn_text: tkinter.StringVar
    _code: tkinter.StringVar
    _stats_inv_fnp: tkinter.BooleanVar
    _indent_weapon_profiles: tkinter.BooleanVar
    _shorten_weapon_abilities: tkinter.BooleanVar
    _separate_abilities: tkinter.BooleanVar
    _add_weapons_to_names: tkinter.BooleanVar
    _clean_profiles: tkinter.BooleanVar
    _show_keywords: tkinter.StringVar
    _status: tkinter.StringVar
    _config: ConfigParser

    def __init__(
            self, master: tkinter.Tk | None = None,
            *,
            code: str | int | None = None,
            filepath: StrPath | None = None,
            **kwargs
        ) -> None:
        if (code or code == 0) and filepath:
            raise ValueError('cannot simultaneously use code and file path')
        elif (code or code == 0) and not lse.validate_code(code):
            raise ValueError('invalid code')
        elif filepath and not validate_filepath(filepath):
            raise ValueError('invalid file path')
        kwargs['padding'] = (10, 6)
        super().__init__(master, **kwargs)
        self.master.title('Localscribe Enhanced')
        self.master.minsize(290, 100)
        self.master.columnconfigure(0, weight=1)
        self.master.rowconfigure(0, weight=1)
        self.columnconfigure(0, weight=0, minsize=50)
        self.columnconfigure(1, weight=0)
        self.columnconfigure(2, weight=0, minsize=50)
        self.grid(sticky=FILL)
        self._code = tkinter.StringVar()
        self._stats_inv_fnp = tkinter.BooleanVar()
        self._indent_weapon_profiles = tkinter.BooleanVar()
        self._shorten_weapon_abilities = tkinter.BooleanVar()
        self._separate_abilities = tkinter.BooleanVar()
        self._add_weapons_to_names = tkinter.BooleanVar()
        self._clean_profiles = tkinter.BooleanVar()
        self._show_keywords = tkinter.StringVar()
        self._status = tkinter.StringVar()
        self._run_btn_text = tkinter.StringVar(value='Run')
        ttk.Label(self, text='Enter Code').grid(columnspan=3)
        code_box = ttk.Entry(self, textvariable=self._code)
        code_box.bind(
            '<Button-3>', lambda _: self._set_code(code_box.clipboard_get()))
        code_box.grid(column=1, sticky=HORZ)
        ttk.Checkbutton(
            self,
            command=lambda: self.update_config('stats_inv_fnp'),
            text='Show Invuln/FNP in stat line',
            variable=self._stats_inv_fnp
        ).grid(column=1, sticky=tkc.W)
        ttk.Checkbutton(
            self,
            command=lambda: self.update_config('indent_weapon_profiles'),
            text='Indent weapon profiles',
            variable=self._indent_weapon_profiles
        ).grid(column=1, sticky=tkc.W)
        ttk.Checkbutton(
            self,
            command=lambda: self.update_config('shorten_weapon_abilities'),
            text='Shorten weapon abilities',
            variable=self._shorten_weapon_abilities
        ).grid(column=1, sticky=tkc.W)
        ttk.Checkbutton(
            self,
            command=lambda: self.update_config('separate_abilities'),
            text='Seperate model and unit abilities',
            variable=self._separate_abilities
        ).grid(column=1, sticky=tkc.W)
        ttk.Checkbutton(
            self,
            command=lambda: self.update_config('add_weapon_to_name'),
            text='Add special weapons to model names',
            variable=self._add_weapons_to_names
        ).grid(column=1, sticky=tkc.W)
        ttk.Checkbutton(
            self,
            command=lambda: self.update_config('clean_profiles'),
            text='Remove duplicate model profile entries',
            variable=self._clean_profiles
        ).grid(column=1, sticky=tkc.W)
        ttk.Label(self, text='Show keywords in unit tooltip:').grid(column=1)
        ttk.Radiobutton(
            self,
            command=lambda: self.update_config('show_keywords'),
            text='All',
            value='all',
            variable=self._show_keywords
        ).grid(column=1, sticky=tkc.W)
        ttk.Radiobutton(
            self,
            command=lambda: self.update_config('show_keywords'),
            text='Filtered',
            value='filtered',
            variable=self._show_keywords
        ).grid(column=1, sticky=tkc.W)
        ttk.Radiobutton(
            self,
            command=lambda: self.update_config('show_keywords'),
            text='None',
            value='',
            variable=self._show_keywords
        ).grid(column=1, sticky=tkc.W)
        ttk.Button(
            self, text='Select File', command=self.select_file).grid(column=1)
        ttk.Button(
            self, text='Save File', command=self.save_file).grid(column=1)
        ttk.Button(
            self, textvariable=self._run_btn_text, command=self.toggle_server
        ).grid(column=1)
        self._status_msg_widget = None
        if code or code == 0:
            if isinstance(code, int):
                code = f'{code:08x}'
            self.code = code
        self.filepath = filepath
        self.read_config()

    @property
    def code(self) -> str:
        return self._code.get()

    @code.setter
    def code(self, value: str | int | None) -> None:
        self._set_code(value)

    def _set_code(
            self,
            code: str | int | None,
            *,
            clear_filepath: bool = True
        ) -> None:
        if not code and code != 0:
            code = ''
        elif not lse.validate_code(code):
            self.status = 'Error: invalid code'
            return
        elif isinstance(code, int):
            code = f'{code:08x}'
            if clear_filepath:
                self.filepath = None
        else:
            code = code.strip()
            if code and clear_filepath:
                self.filepath = None
        self._code.set(code)

    @property
    def filepath(self) -> Path | None:
        return self._filepath

    @filepath.setter
    def filepath(self, value: StrPath | None) -> None:
        self._set_filepath(value)

    def _set_filepath(
            self, filepath: StrPath | None, *, clear_code: bool = True):
        if filepath is not None:
            if not validate_filepath(filepath):
                self.status = 'Error: invalid file path'
                return
            if clear_code:
                self.code = ''
            if isinstance(filepath, str):
                filepath = filepath.strip(' "\'')
            filepath = Path(filepath)
            self.status = f'Loaded file {filepath.name}'
        self._filepath = filepath

    @property
    def stats_inv_fnp(self) -> bool:
        return self._stats_inv_fnp.get()

    @stats_inv_fnp.setter
    def stats_inv_fnp(self, value: bool) -> None:
        self._stats_inv_fnp.set(value)

    @property
    def indent_weapon_profiles(self) -> bool:
        return self._indent_weapon_profiles.get()

    @indent_weapon_profiles.setter
    def indent_weapon_profiles(self, value: bool) -> None:
        self._indent_weapon_profiles.set(value)

    @property
    def shorten_weapon_abilities(self) -> bool:
        return self._shorten_weapon_abilities.get()

    @shorten_weapon_abilities.setter
    def shorten_weapon_abilities(self, value: bool) -> None:
        self._shorten_weapon_abilities.set(value)

    @property
    def separate_abilities(self) -> bool:
        return self._separate_abilities.get()

    @separate_abilities.setter
    def separate_abilities(self, value: bool) -> None:
        self._separate_abilities.set(value)

    @property
    def add_weapons_to_names(self) -> bool:
        return self._add_weapons_to_names.get()

    @add_weapons_to_names.setter
    def add_weapons_to_names(self, value: bool) -> None:
        self._add_weapons_to_names.set(value)

    @property
    def clean_profiles(self) -> bool:
        return self._clean_profiles.get()

    @clean_profiles.setter
    def clean_profiles(self, value: bool) -> None:
        self._clean_profiles.set(value)

    @property
    def show_keywords(self) -> Literal['all', 'filtered'] | None:
        return self._show_keywords.get() or None  # pyright: ignore[reportReturnType]

    @show_keywords.setter
    def show_keywords(self, value: Literal['all', 'filtered'] | None) -> None:
        sk = value or ''
        self._show_keywords.set(sk)

    @property
    def status(self) -> str:
        return self._status.get()

    @status.setter
    def status(self, status: str) -> None:
        self._status.set(status)

    @property
    def _status_msg(self) -> tkinter.Message:
        if not self._status_msg_widget:
            self._status_msg_widget = tkinter.Message(
                self, textvariable=self._status, width=250)
            self._status_msg_widget.grid(column=0, columnspan=3)
        return self._status_msg_widget

    def read_config(self) -> None:
        config_path = Path('config.ini')
        if not config_path.is_file():
            with (
                    open(config_path, 'wb') as new,
                    open(f'{__file__}/../_config.ini', 'rb') as default
                ):
                new.write(default.read())
        self._config = ConfigParser(allow_no_value=True)
        self._config.optionxform = lambda optionstr: (
            o if (o := optionstr.casefold()) in CONFIG_KEYS else optionstr)
        self._config.read(config_path)
        for attr in BOOL_KEYS:
            setattr(
                self, attr, self._config['General'].getboolean(attr, False))
        try:
            show_keywords = self._config['General']['show_keywords']
        except KeyError:
            pass
        else:
            if (sk := show_keywords.casefold()) in ('all', 'filtered'):
                self.show_keywords = sk
            elif sk == 'none':
                self.show_keywords = None
            elif self._config['General'].getboolean('show_keywords', False):
                self.show_keywords = 'filtered'

    def update_config(self, option: str) -> None:
        self._config['General'][option] = str(getattr(self, option)).casefold()
        with open('config.ini') as f:
            text = f.readlines()
        for i, line in enumerate(text):
            if line.strip().casefold().startswith(option):
                text[i] = f'{option} = {self._config['General'][option]}\n'
                break
        else:
            return
        with open('config.ini', 'w') as f:
            f.writelines(text)

    def toggle_server(self) -> None:
        if self.stop_server():
            self._run_btn_text.set('Run')
            self.status = 'Server stopped.'
            del self._server
        else:
            self.start_server()
            self._run_btn_text.set('Stop')

    def start_server(self) -> None:
        if self._check_autosave_code():
            roster, self.status = self.load_file()
        else:
            roster, self.status = self.download()
        if not roster:
            self._status_msg['foreground'] = 'red'
            return
        self._status_msg['foreground'] = 'black'
        self._config.read('config.ini')
        try:
            ignored_keywords = self._config.options('IgnoredKeywords')
        except KeyError:
            ignored_keywords = []
        add_abilities: dict[frozenset[frozenset[str]], dict[str, str]] = {}
        replace_abilities: dict[frozenset[frozenset[str]], dict[str, str]] = {}
        hide_abilities: dict[frozenset[frozenset[str]], set[str]] = {}
        add_weapon_abilites: dict[tuple[str | None, str], dict[str, str]] = {}
        for section, values in self._config.items():
            action, _, keys = section.partition('|')
            action = action.strip()
            key = lse.create_filter(keys)
            match action:
                case 'AddAbility':
                    add_abilities[key] = dict(values)
                case 'ReplaceAbility':
                    replace_abilities[key] = dict(values)
                case 'HideAbility':
                    hide_abilities[key] = set(values.keys())
                case 'AddWeaponAbility':
                    weapon, _, ability = keys.rpartition('.')
                    add_weapon_abilites[(weapon, ability)] = dict(values)
        roster_json = lse.create_json(
            roster,
            statsInvFNP=self.stats_inv_fnp,
            indentWeaponProfiles=self.indent_weapon_profiles,
            shortenWeaponAbilities=self.shorten_weapon_abilities,
            separateAbilities=self.separate_abilities,
            showKeywords=self.show_keywords,
            ignoredKeywords=ignored_keywords,
            addAbilities=add_abilities,
            replaceAbilities=replace_abilities,
            hideAbilities=hide_abilities,
            addWeaponAbilities=add_weapon_abilites,
            addWeaponsToNames=self.add_weapons_to_names,
            cleanProfiles=self.clean_profiles,
        )
        self._server = multiprocessing.Process(
            target=lse.run_server, args=(roster_json,),
            daemon=True
        )
        self._server.start()
        atexit.register(self._server.terminate)

    def download(self) -> tuple[bytes | None, str]:
        try:
            roster = lse.download(self.code, embed_code=True)
        except ValueError:
            # If no code or an invalid code is provided, use a backup of
            # the last successful download.
            status = (
                'Download unsuccessful' if self.code else 'No code provided')
            try:
                with open(AUTOSAVE, 'rb') as f:
                    roster = f.read()
            except FileNotFoundError:
                try:
                    with open('roster.bin', 'rb') as f:
                        roster = f.read()
                except FileNotFoundError:
                    status = f'{status}, no saved data found.'
                    return None, status
                else:
                    try:
                        with open(AUTOSAVE, 'wb') as f:
                            f.write(roster)
                    except PermissionError as e:
                        print(e)
                    status = (
                        f'{status}, loading saved data and starting server.')
            else:
                status = (
                    f'{status}, loading saved data and starting server.')
        else:
            status = 'Download successful, starting server.'
            # Backup downloaded data.
            try:
                with open(AUTOSAVE, 'wb') as f:
                    f.write(roster)
            except PermissionError:
                pass
        return roster, status

    def select_file(self) -> None:
        self.filepath = tkfiledialog.askopenfilename(**FILE_DIALOG_KWARGS)

    def load_file(self) -> tuple[bytes | None, str]:
        roster = None
        filepath = self.filepath or AUTOSAVE
        if filepath:
            try:
                with open(filepath, 'rb') as f:
                    roster = f.read()
            except PermissionError:
                status = 'Unable to open file.'
            except FileNotFoundError:
                status = 'File not found.'
            else:
                status = 'Roster loaded, starting server.'
        else:
            status = 'No file selected.'
        return roster, status

    def save_file(self, roster: bytes | None = None) -> None:
        if (
                not roster
                and not (self.filepath and self.filepath.is_file())
                and not AUTOSAVE.is_file()
            ):
            # notify
            return
        path = tkfiledialog.asksaveasfilename(**FILE_DIALOG_KWARGS)
        if path:
            if (
                    roster
                    or (
                        not self.filepath
                        and not self._check_autosave_code()
                        and (roster := self.download()[0])
                    )
                ):
                with open(path, 'wb') as f:
                    f.write(roster)
            else:
                prev_path = self.filepath or AUTOSAVE
                with open(prev_path, 'rb') as fr, open(path, 'wb') as fw:
                    fw.write(fr.read())
                if self.filepath:
                    self._set_filepath(path, clear_code=False)
        else:
            # notify
            pass

    def stop_server(self) -> bool:
        try:
            self._server.terminate()
        except AttributeError:
            return False
        else:
            atexit.unregister(self._server.terminate)
            return True

    def _check_autosave_code(self) -> bool:
        if not self.code:
            return False
        try:
            with open(AUTOSAVE, 'rb') as f:
                roster: Roster = json.load(f)
        except FileNotFoundError:
            return False
        return self.code == roster.get('code')

    @override
    def destroy(self):
        self.stop_server()
        return super().destroy()


def validate_filepath(path: StrPath | None) -> bool:
    if path is None:
        return False
    elif isinstance(path, str):
        path = path.strip(' "\'')
    try:
        path = Path(path)
    except (TypeError, ValueError):
        return False
    else:
        valid_name = any(
            fnmatch(path.name, p) for p in ('*.lsroster', '*.json'))
        return path.is_file() and valid_name


if __name__ == '__main__':
    import argparse


    multiprocessing.freeze_support()
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'source',
        nargs='?',
        help='roster file path or army code from yellowscribe.xyx'
    )
    args = parser.parse_args()
    source: str = args.source
    kwargs: dict[str, Any] = {}
    if lse.validate_code(source):
        kwargs['code'] = source
    elif validate_filepath(source):
        kwargs['filepath'] = source
    try:
        LocalscribeGUI(**kwargs).mainloop()
    except Exception as exc:
        with open('crash.log', 'w') as f:
            traceback.print_exception(exc, file=f)
        raise exc
