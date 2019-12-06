#!/usr/bin/env python3

import subprocess
from collections import namedtuple

def run(cmd):
	Result = namedtuple('Result', 'status stdout stderr')
	res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
	return Result(status=res.returncode, stdout=res.stdout.decode(), stderr=res.stderr.decode())

def try_run(cmd):
	res = run(cmd)
	if res.status != 0:
		print(f'Command \'{cmd}\' failed with stderr:')
		print(res.stderr, end='')
		exit(1)
	return res.stdout

try:
	with open('.manifest', 'r') as f:
		src = f.read().strip()
except:
	print('.manifest file does not exist!')
	exit(1)

assignments = []	
for line_num, line in enumerate(src.split('\n')):
	parts = line.split(' ')
	if len(parts) != 3 or parts[1] != '->':
		print(f'Invalid formatting in .manifest file (line {line_num+1})')
	else:
		assignments.append((parts[0], parts[2]))

for (source, dest) in assignments:
	real_source = try_run(f'realpath "{source}"').strip()
	try_run(f'ln -f --symbolic "{real_source}" "{dest}"')
