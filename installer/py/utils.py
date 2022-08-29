from typing import NoReturn as _NoReturn

import hashlib as _hashlib
import os as _os
import sys as _sys

PROGRAM = _os.path.basename(_sys.argv[0])
if 'PROGRAM' in _os.environ:
    PROGRAM = _os.environ['PROGRAM']

def die(reason: str, code=1) -> _NoReturn:
    print(f"{PROGRAM}: {reason}", file=_sys.stderr)
    exit(code)

def checksum(file: str) -> str:
    sha512 = _hashlib.sha512()
    with open(file, 'rb') as handle:
        while True:
            buf = handle.read(4096)
            if not buf:
                break
        sha512.update(buf)
    return sha512.hexdigest()

class Problem(Exception):
    def __init__(self, *args: object, file=None, tip=None, fatal=False) -> None:
        super().__init__(*args)
        self.file = file
        self.tip = tip
        self.fatal = fatal

    def __str__(self):
        buf = [f"{PROGRAM}: {super().__str__()}"]
        
        if self.file is not None:
            buf.append(f" ... in file: {self.file}")

        if self.tip is not None:
            buf.append(f" ... {self.tip}")
        
        return "\n".join(buf)
