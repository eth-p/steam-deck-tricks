#!/usr/bin/env python
import sys
import yaml

from operations import uninstall, is_valid
from utils import die

db = yaml.safe_load(sys.stdin)
for operation in reversed(db['files']):
    op_type = operation['==']
    if not op_type in uninstall:
        die(f"unsupported installer operation: {op_type}")
    
    del(operation['=='])
    is_valid[op_type](**operation)
    uninstall[op_type](**operation)
