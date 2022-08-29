import os
from os import path

from utils import Problem


def install(destination=None, permission=None, transient=False):
	print(f"create dir: {destination}")
	os.mkdir(destination, mode=permission)


def uninstall(destination=None, permission=None, transient=False):
	if transient and path.exists(destination):
		print(f"delete dir: {destination}")
		os.rmdir(destination)


def is_valid(**kwargs):
	if 'destination' not in kwargs: raise Problem("destination not provided by file database")
	if 'permission' in kwargs and not isinstance(kwargs['permission'], int): raise Problem("permissions is not integer")
	pass
