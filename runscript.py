#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals, print_function

import sys
import os
import pwd

import subprocess


def get_username():
    return pwd.getpwuid( os.getuid() )[ 0 ]

# print('UID: %s' % os.getuid())
# print('Current User: %s' % get_username())

from tabulate import tabulate


SCRIPTSDIR = os.getenv('SCRIPTS_DIR', './scripts')
HELPKEY = 'help'
COMMANDPREFIX = 'docker run [OPTIONS] IMAGE'
RESERVEDNAMES = []
SCRIPTEXTENSIONS = ['.sh', '.py']


def _p(txt):
    print(txt)


def get_caption(path, name):
    result = None
    captionfile = os.path.join(path, '%s.txt' % name)
    if name and os.path.exists(captionfile):
        with open(captionfile, 'rb') as fh:
            result = fh.readline()  # Only take first line!
    return result.strip() if result else ''


def assert_no_reserved_name(name):
    assert os.path.splitext(name)[0] not in RESERVEDNAMES, 'Reserved filename: %s' % name


def build_command(cmdpath, prefix=True):
    result = ' '.join(cmdpath)
    if prefix:
        result = '%s %s' % (COMMANDPREFIX, result)
    return result.rstrip()


def get_script(path, name):
    files = [filename for filename in os.listdir(path) if os.path.isfile(os.path.join(path, filename))]

    candidates = []
    for f in files:
        parts = os.path.splitext(f)
        if parts[1] not in SCRIPTEXTENSIONS:
            continue
        if parts[0] == name:
            candidates.append(f)

    if len(candidates) > 1:
        raise Exception('Script ambiguity: two scripts in the same directory have the same basename: %r' % candidates)
    elif len(candidates) == 0:
        return None
    return candidates[0]


def help(path, cmdpath):
    dirs = [dirname for dirname in os.listdir(path) if os.path.isdir(os.path.join(path, dirname))]
    files = [filename for filename in os.listdir(path) if os.path.isfile(os.path.join(path, filename))]

    headers = ['Command', 'Description']
    descriptions = []

    for d in dirs:
        assert_no_reserved_name(d)
        descriptions.append([d, get_caption(path, d)])

    for f in files:
        assert_no_reserved_name(f)
        if os.path.splitext(f)[1] not in SCRIPTEXTENSIONS:
            continue
        name = os.path.splitext(f)[0]
        descriptions.append([name, get_caption(path, name)])

    descriptions.append(['help', 'Show this message'])

    # Sort commands
    descriptions = sorted(descriptions, key=lambda tup: tup[0])

    _p('')
    _p('Usage: %s [COMMAND] [ARG...]' % build_command(cmdpath))
    _p('')
    _p('Valid options for [COMMAND]:')
    _p('')
    _p(tabulate(descriptions, headers))


def run_command(command):
    return subprocess.call(command, env=os.environ.copy())


def run(args, path=None, cmdpath=None):
    # Current path
    path = path or SCRIPTSDIR

    # Current command path
    cmdpath = cmdpath or []

    # Take first element
    arg = args[0]

    # Check for 'help'
    if arg == HELPKEY:
        return help(path, cmdpath=cmdpath)
    elif os.path.isdir(os.path.join(path, arg)):
        cmdpath.append(arg)
        if len(args) > 1:
            # We have more commands
            return run(args[1:], path=os.path.join(path, arg), cmdpath=cmdpath)
        return help(os.path.join(path, arg), cmdpath=cmdpath)

    scriptfile = get_script(path, arg)
    if not scriptfile:
        return help(path, cmdpath=cmdpath)

    if os.path.isfile(os.path.join(path, scriptfile)):
        command = [os.path.abspath(os.path.join(path, scriptfile))]
        command.extend(args[1:])
        returncode = run_command(command)
        exit(returncode)


if __name__ == '__main__':
    usage = ''

    if len(sys.argv) == 1:
        help(SCRIPTSDIR, [])
    else:
        run(sys.argv[1:])
