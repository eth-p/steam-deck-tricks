import os
import shutil

from utils import Problem
from utils import checksum as create_checksum


def install(source=None, destination=None, permission=0o0644, checksum=None):
	print(f"create file: {destination}")

	# Check if the destination already exists.
	# If the contents are the same as the checksum of the file to-be-installed, assume it
	# has already been installed and return early. Otherwise, raise an error.
	if os.path.exists(destination):
		current_checksum = create_checksum(destination)
		if current_checksum == checksum:
			return

		raise Problem(
			"file already exists",
			file=destination,
		)
	
	# Copy the file and change its permissions.
	shutil.copyfile(source, destination)
	os.chmod(destination, permission)
	

def uninstall(source=None, destination=None, permission=None, checksum=None):
	print(f"delete file: {destination}")

	# If the file does not exist, the result is the same.
	if not os.path.exists(destination):
		return

	# Check to see if the file has the same checksum as the one provided by the file database.
	# If it's different, something has changed the file and we don't want to automatically delete it.
	current_checksum = create_checksum(destination)
	if current_checksum != checksum:
		raise Problem(
			"file has been modified since install",
			file=destination,
			tip="Delete the file and retry."
		)

	# Delete the file.
	os.unlink(destination)


def is_valid(**kwargs):
	if 'checksum' not in kwargs: raise Problem("checksum not provided by file database")
	if 'source' not in kwargs: raise Problem("source not provided by file database")
	if 'destination' not in kwargs: raise Problem("destination not provided by file database")

	if 'permission' in kwargs and not isinstance(kwargs['permission'], int):
		raise Problem("permissions is not integer")
	
	pass
