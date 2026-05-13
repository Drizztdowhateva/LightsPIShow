
import sys
import time

# Start the test mode
proc = subprocess.Popen(["python3", "into.py", "--test", "--speed", "5"], 
                       stdout=subprocess.PIPE, 
                       stderr=subprocess.STDOUT, 
                       stdin=subprocess.PIPE,
                       text=True)

# Read initial menu
print("=== Initial Menu ===")
for _ in range(15):
    line = proc.stdout.readline()
    if line:
        print(line.rstrip())
    else:
        break

# Send T key to start preview
print("
=== Sending T key ===")
proc.stdin.write("T")
proc.stdin.flush()

# Read preview output
print("
=== Preview Output ===")
for _ in range(60):  # Read up to 60 lines
    line = proc.stdout.readline()
    if line:
        print(line.rstrip())
        if "Complete" in line:
            break
    else:
        break

proc.terminate()
