#!/usr/bin/env python3
"""
  Scyther : An automatic verifier for security protocols.
  Copyright (C) 2007-2020 Cas Cremers
  
  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
"""


def write_tag(tag=None):
    """
    Write tag file
    """
    if tag is None:
        tag = "unknown"
    fp = open('version.h', 'w')
    s = "#define TAGVERSION \"%s\"\n" % tag
    fp.write(s)
    fp.close()


def get_description():
    """
    If possible, use Git to extract a description of the current commit
    """

    try:
        import sys
        import subprocess
        res = subprocess.check_output(["git", "describe", "--tags", "--dirty"] + sys.argv[1:])
        res = res.strip()
    except:
        res = None

    return res


if __name__ == '__main__':
    tag = get_description()
    write_tag(tag)
