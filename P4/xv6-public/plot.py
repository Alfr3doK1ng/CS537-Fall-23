import re
import matplotlib.pyplot as plt
from collections import defaultdict

# Step 1: Read the data from the file
filename = 'log.txt'
with open(filename, 'r') as file:
    log_data = file.readlines()

p = [[0 for _ in range(538)] for _ in range(8)]
for log in log_data:
    # Parse the necessary data using regex
    match = re.match(r'current total ticks, pid, current_ticks: (\d+) (\d+) (\d+)', log)
    if match:
        total_ticks, pid, current_ticks = match.groups()
        p[int(pid)][int(total_ticks)] = int(current_ticks)

        # Append the current tick to the appropriate process's list

for i in range(1, 8):
    for j in range(1, 538):
        if p[i][j] == 0:
            p[i][j] = p[i][j-1]

# Step 3: Plot the data
fig, ax = plt.subplots()

# We will generate a list of all ticks for plotting on the x-axis
all_ticks = list(range(0, int(total_ticks) + 1))


# Create a line for each process
for i in range(1,8):
    # The y-values are the ticks; we must generate the x-values
    # For each tick, we need to find the corresponding "time" at which it occurred
    # If the process did not run on a tick, we will use None to avoid drawing a line segment
    execution = p[i]
    print(all_ticks)
    print(execution)

    ax.plot(all_ticks, execution, marker='o', linestyle='-', markersize=4, label=f'Process {i}')

ax.set_xlabel('Ticks')
ax.set_ylabel('Execution')
ax.set_title('Process execution over time')
ax.legend()

plt.show()
