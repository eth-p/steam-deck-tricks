#!/usr/bin/env python
import sys
import yaml

from operations import install, is_valid
from utils import die, Problem

db = yaml.safe_load(sys.stdin)
for operation in db['files']:
    op_type = operation['==']
    if not op_type in install:
        die(f"unsupported installer operation: {op_type}")
    
    try:
        del(operation['=='])
        is_valid[op_type](**operation)
        install[op_type](**operation)
    except Problem as problem:
        print(str(problem), file=sys.stderr)
        if problem.fatal:
            break
