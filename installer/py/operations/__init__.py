from os import path as _path
import os as _os

install = {}
uninstall = {}
is_valid = {}

# Read through all the files in the current directory and export them under the `install` and `uninstall` dicts.
for _file in _os.listdir(_path.dirname(__file__)):
	if _file.startswith("_") or not _file.endswith(".py"):
		continue
	
	_name = _path.splitext(_file)[0];
	_operation = getattr(__import__(f"{__package__}.{_name}"), _name)
	
	install[_name] = _operation.install
	uninstall[_name] = _operation.uninstall
	is_valid[_name] = _operation.is_valid
