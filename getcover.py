#!/usr/bin/python3

import requests
import binascii
import os
import sys


def searchcover(rom):
    baseurl = "https://art.gametdb.com/ds/coverS/"
    langList = ['EN/', 'US/', 'JA/', 'DE/', 'KO/']
    filename = tid + '.png'
    for lang in langList:
        if not nds_rom:
            baseurl = 'https://github.com/DefKorns/rom-cover-generator/raw/master/boxart/'
            lang = ''

        url = baseurl + lang + filename

        r = requests.get(url)
        if r.status_code == 200:
            if not nds_rom:
                filename = rom_title + rom_extension + '.png'

            with open(filename, 'wb') as f:
                f.write(r.content)
                if not nds_rom:
                    continue
                else:
                    break


def gettid(romfile):
    if os.path.isfile(romfile):
        with open(romfile, 'rb') as f:
            f.seek(12)
            return f.read(4).decode("utf-8")


def romCRC32(romfile):
    with open(romfile, "rb") as f:
        buf = (binascii.crc32(f.read()) & 0xFFFFFFFF)
        return "%08X" % buf


def rename(old_file, new_file):
    if os.path.isfile(old_file):
        os.rename(old_file, new_file)


def remove(filetodelete):
    if os.path.isfile(filetodelete):
        os.remove(filetodelete)


def valid_arg(arg, multilist):
    isValid = any(arg in sublist for sublist in multilist)
    return isValid


def help():
    print("\nUsage: \n    python ", os.path.basename(
        __file__), "titleID | ndsfile [titleID] | ndsfile | files | [options]...")
    print("\nFiles: \n    Rom files of type: \"nes\", \"snes\", \"gb\", \"gbc\", \"sms\", \"gen\", \"gg\", \"md\", \"nds\"")
    print("\nOptions: \n    -?, -h, -help			This information screen")
    print("    md                                Convert Mega Drive roms \".md\" to nds compatible roms \".gen\" and gets it's artwork")
    print("    -png                                Optimize png files")
    print("\nExamples: \n    python ", os.path.basename(
        __file__), ".nes        Rename matching title \"png\" files to the rom CRC")
    print("    python ", os.path.basename(
        __file__), "-?         Display help info")
    print("    python ", os.path.basename(
        __file__), "-png       Compress \"png\" files")
    sys.exit()


if len(sys.argv) == 1:
    help()

for arg in sys.argv:
    helpArgs = ['help', '-h', '-?']
    romArgs = ['snes', 'gbc', 'nes', 'gb', 'sms', 'gen', 'gg', 'md']
    allRoms = ['all', '-a', '*.*']
    arg_list = [helpArgs, romArgs, 'nds', allRoms]

if not valid_arg(arg, arg_list):
    help()

if arg in helpArgs:
    help()

if arg == 'nds':
    nds_rom = True
    for romfile in os.listdir("."):
        if romfile.endswith('.'+arg):
            tid = gettid(romfile)
            searchcover(tid)

if arg in romArgs:
    nds_rom = False
    for romfile in os.listdir("."):
        if romfile.endswith('.' + arg):
            tid = romCRC32(romfile)
            rom_title, rom_extension = os.path.splitext(romfile)
            if arg == 'md':
                rom_extension = 'gen'
                rename(romfile, rom_title + rom_extension)
            searchcover(tid)

if arg in allRoms:
    print('soon')
    sys.exit()
