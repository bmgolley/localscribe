from __future__ import annotations

import atexit
import multiprocessing
import tkinter
import traceback
from configparser import ConfigParser
from pathlib import Path
from tkinter import constants as tkc
from tkinter import filedialog as tkfiledialog
from tkinter import ttk
from typing import Literal, override

import localscribe_enhanced


HORZ = tkc.E + tkc.W
"""Stretch horizontally."""
VERT = tkc.N + tkc.S
"""Stretch Vertically."""
FILL = HORZ + VERT
"""Stretch to fill the availible space."""


CONFIG_KEYS = (
    'stats_inv_fnp', 'indent_weapon_profiles', 'shorten_abilites',
    'show_keywords', 'separate_abilities'
)


class LocalscribeGUI(ttk.Frame):
    master: tkinter.Tk
    _status_msg: tkinter.Message | None
    _server: multiprocessing.Process
    """Running server process."""
    _run_btn_text: tkinter.StringVar
    _code: tkinter.StringVar
    _stats_inv_fnp: tkinter.BooleanVar
    _indent_weapon_profiles: tkinter.BooleanVar
    _shorten_weapon_abilities: tkinter.BooleanVar
    _separate_abilities: tkinter.BooleanVar
    _show_keywords: tkinter.StringVar
    _status: tkinter.StringVar
    _config: ConfigParser

    def __init__(self, master: tkinter.Tk | None = None) -> None:
        super().__init__(master, padding=(10, 6))
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
        self._show_keywords = tkinter.StringVar()
        self._status = tkinter.StringVar()
        self._run_btn_text = tkinter.StringVar(value='Run')
        ttk.Label(self, text='Enter Code').grid(columnspan=3)
        code_box = ttk.Entry(self, textvariable=self._code)
        code_box.bind(
            '<Button-3>',
            lambda _: self._code.set(code_box.clipboard_get().strip())
        )
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
            self, textvariable=self._run_btn_text, command=self.toggle_server
        ).grid(column=1)
        self._status_msg = None
        self.read_config()

    @property
    def code(self) -> str:
        return self._code.get()

    @code.setter
    def code(self, value: str) -> None:
        self._code.set(value.strip())

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
        for attr in (
                'stats_inv_fnp', 'indent_weapon_profiles',
                'shorten_weapon_abilities', 'separate_abilities'
            ):
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
        if not self._status_msg:
            self._status_msg = tkinter.Message(
                self, textvariable=self._status, width=250)
            self._status_msg.grid(column=0, columnspan=3)
        roster, self.status = self.load_download()
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
            key = localscribe_enhanced.create_filter(keys)
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
        roster_json = localscribe_enhanced.create_json(
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
            addWeaponAbilities=add_weapon_abilites
        )
        self._server = multiprocessing.Process(
            target=localscribe_enhanced.run_server, args=(roster_json,),
            daemon=True
        )
        self._server.start()
        atexit.register(self._server.terminate)

    def load_download(self) -> tuple[bytes | None, str]:
        try:
            roster = localscribe_enhanced.download(self.code)
        except ValueError:
            # If no code or an invalid code is provided, use a backup of
            # the last successful download.
            status = (
                'Download unsuccessful' if self.code else 'No code provided')
            try:
                with open('roster.bin', 'rb') as f:
                    roster = f.read()
            except FileNotFoundError:
                status = f'{status}, no saved data found.'
                return None, status
            else:
                status = (
                    f'{status}, loading saved data and starting server.')
        else:
            status = 'Download successful, starting server.'
            # Backup downloaded data.
            try:
                with open('roster.bin', 'wb') as f:
                    f.write(roster)
            except PermissionError:
                pass
        return roster, status

    def load_file(self) -> tuple[bytes | None, str]:
        path = tkfiledialog.askopenfilename(
                defaultextension='.lsroster',
                filetypes=(('Localscribe Roster', '.lsroster'),)
            )
        roster = None
        if path:
            try:
                with open(path, 'rb') as f:
                    roster = f.read()
            except PermissionError:
                status = 'Insufficient permissions to open file.'
            except FileNotFoundError:
                status = 'File not found.'
            else:
                status = 'Roster loaded, starting server.'
        else:
            status = 'No file selected.'
        return roster, status

    def stop_server(self) -> bool:
        try:
            self._server.terminate()
        except AttributeError:
            return False
        else:
            atexit.unregister(self._server.terminate)
            return True

    @override
    def destroy(self):
        self.stop_server()
        return super().destroy()


if __name__ == '__main__':
    multiprocessing.freeze_support()
    try:
        LocalscribeGUI().mainloop()
    except Exception as exc:
        with open('crash.log', 'w') as f:
            traceback.print_exception(exc, file=f)
        raise exc
