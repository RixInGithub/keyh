import subprocess
import time

process = subprocess.Popen(
	["helper.exe"],
	stdin=subprocess.PIPE,
	stdout=subprocess.DEVNULL,
	stderr=subprocess.DEVNULL,
	text=True
)

time.sleep(0.9)
while True:
	time.sleep(0.1)
	process.stdin.write("0\n")
	process.stdin.flush()
	time.sleep(0.1)
	process.stdin.write("1\n")
	process.stdin.flush()