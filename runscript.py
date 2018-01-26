#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals, print_function
import sys
import os
import pwd
import subprocess

from tabulate import tabulate

if sys.version_info[0] == 2:
    from codecs import open  # pylint: disable=redefined-builtin

SCRIPTSDIR = os.getenv('SCRIPTS_DIR', './scripts')
HELPKEY = 'help'
COMMANDPREFIX = 'docker run [OPTIONS] IMAGE'
RESERVEDNAMES = []
SCRIPTEXTENSIONS = ['.sh', '.py']

echo = print # noqa


def get_username():
    return pwd.getpwuid(os.getuid())[0]


def get_caption(path, name):
    result = None
    captionfile = os.path.join(path, '%s.txt' % name)
    if name and os.path.exists(captionfile):
        with open(captionfile, mode='r', encoding='utf8') as fh:
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
        raise Exception('Script ambiguity: two scripts in the same directory '
                        'have the same basename: {}'.format(candidates))
    elif len(candidates) == 1:
        return candidates[0]

    return None


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

    echo('')
    echo('Usage: {} [COMMAND] [ARG...]'.format(build_command(cmdpath)))
    echo('')
    echo('Valid options for [COMMAND]:')
    echo('')
    echo(tabulate(descriptions, headers))


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
