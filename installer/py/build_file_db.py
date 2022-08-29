#!/usr/bin/env python
# ---------------------------------------------------------------------------------------------------------------------
# steam-deck-tricks | https://github.com/eth-p/steam-deck-tricks/
#
# Python script that converts the output of the TWEAKBUILD install DSL into a file database for the installer scripts.
# This is also responsible for creating install instructions for creating the parent directories ahead of time.
# ---------------------------------------------------------------------------------------------------------------------
from os import path
import sys
import yaml

from utils import checksum, die

operations = []
dirs_checked = set()

def ensuredirs(dir):
	"""
	Ensures directories are created before any file operations take place.
	This will add the directories in parent->child order to the operations list.
	"""
	dirs = []
	while dir := path.dirname(dir):
		if dir in dirs_checked:
			break

		dirs_checked.add(dir)
		
		# If the path already exists but is not a directory, we can't proceed.
		# Installation would either mangle something or fail.
		if path.exists(dir) and not path.isdir(dir):
			die(f"expected '{dir}' to be a directory, but it was not")
		
		# If the directory already exists, we can stop.
		if path.exists(dir):
			break

		# Since the directory does not exist alreay
		dirs.append({
			'==': 'v1_mkdir',
			'destination': dir,
			'permission': 0o700,
			'transient': True,
		})
	
	# Append the mkdir ops to the operations list.
	dirs.reverse()
	operations.extend(dirs)


for doc in yaml.safe_load_all(sys.stdin):
	dsl  = doc['dsl'].lower()
	data = doc['data']

	# DSL: done
	# Internal operation that signals the generated file DB should be flushed to STDOUT.
	if dsl == "done":
		yaml.safe_dump({
			'meta': {
				'tweak': sys.argv[1],
				'version': sys.argv[2],
			},
			'files': operations
		}, sys.stdout)
		exit(0)
	
	# DSL: put
	# Copy a file from the tweak folder to the local filesystem.
	if dsl == "put":
		if 'permission' in data and not isinstance(data['permission'], int):
			data['permission'] = int(data['permission'], 8)
		
		ensuredirs(data['destination'])
		operations.append({
			**data,
			'==': 'v1_create',
			'checksum': checksum(data['source']),
		})

		continue

	die(f"unknown action type {doc['type']}")

die("did not receive 'done' action")
