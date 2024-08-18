# FEATURES

* Local server
Uses a local server for TTS to connect to. Not limited to 10 minutes

* Coherency check ignores dead models
Checking for coherency ignores models with 0 wounds remaining

* Attach Leader units
Attach Leader units to Bodyguard units for coherency checking

* Num 0 as modifier
Num 0 is now a modifier key. No more accidentally changing the model base

Keys:
1: datasheet
2: decrease wounds
3: increase wounds
4: decrease measure radius
5: increase measure radius
8: toggle rectangular base
0+1: crusade sheet
0+6: previous model base
0+7: next model base


# INSTALLATION

Place the two files inside 'TTS Save' in your TTS saves directory (usually found at ~\Documents\My Games\Tabletop Simulator\Saves).

'LocalscribeEnhanced.exe' can be placed anywhere.


# USE

Use the Yellowscribe site (yellowscribe.xyz) as normal.

Run LocalscribeEnhanced.exe and enter the Yellowscribe code. Set any desired options and press 'Run'. A status message will appear under the button.

On a successful download, the raw data will be saved as 'roster.bin'. On an unsuccessful download, or if no code was provided, the program will load from this file if present.


# OPTIONS

## Shorten weapon abilites

Most weapon abilites in tooltips are replaced by a shortened version (e.g. Rapid Fire 1 becomes RF1, Hazardous becomes HZ). Special/unique abilities are replaced by "*". Ability descriptions in the datacard are unchanged.

## Show keywords in unit tooltip

Adds a "Keywords" section to the bottom of a unit's tooltip. "All" adds all keywords, including faction keywords. "Filtered" removes keywords that are unneeded on the battlefield (e.g. "Imperium", "Epic Hero"), while leaving useful ones (e.g. "Grenades", "Smoke"). Keywords in the datacard are unchanged.

## Config

Options are saved in a "config.ini" file. Add or remove keywords to ignore in the "IgnoredKeywords" section. If this file does not exist, it will be created at launch. The options can be edited while the program is running, but if the server is running changes will not take effect until the server is restarted.


# OTHER

TTSMapSort.exe is a Python program that will sort 40k maps from the workshop into individual folders based on battle size.


# SOURCE

localscribe_enhanced.py is the source code for the exe and is included for completeness (I like open source). Running the script directly requires at least Python 3.10, but doesn't require anything outside of the standard libraries. The exe provided contains both the script itself and the Python interpreter.
localscribe_gui.py creates the GUI.
baseScript_enhanced.lua is the updated script that goes on the models. This is usually provided by the Yellowscribe site, but the this program overwrites that with the content of this file.

The other files should be self-explainitory.


# SCRIPT USE

Run localscribe_enhanced.py from the command line/PowerShell/Terminal. (You can launch this in the correct folder by shift-right clicking on the empty space in a folder and selecting the option from the context menu.)

The syntax for the script is:

python localscribe_enhanced.py [code]

where [code] is the string provided from the site.

If you're using PowerShell, that line will need to be:
python .\localscribe_enhanced.py [code]
