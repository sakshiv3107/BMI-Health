import os
import re

log_path = r"C:\Users\SAKSHI\.gemini\antigravity-ide\brain\c959bbcc-26c1-4ad1-b564-7279e782cd11\.system_generated\tasks\task-129.log"
project_root = r"c:\Project\Assignment\IV_Innovation\assignment"

with open(log_path, "r", encoding="utf-8") as f:
    log_content = f.read()

# Pattern to match lines like:
#   error - Invalid constant value - lib\features\bmi\screens\bmi_dashboard_screen.dart:509:42 - invalid_constant
pattern = r"lib[\\/][a-zA-Z0-9_\\/\.]+\.dart:\d+:\d+"
matches = re.findall(pattern, log_content)

errors = []
for m in matches:
    # m is like: lib\features\bmi\screens\bmi_dashboard_screen.dart:509:42
    parts = m.split(":")
    rel_path = parts[0]
    line_num = int(parts[1])
    errors.append((rel_path, line_num))

# Group by file and sort line numbers in descending order (so we don't mess up offsets if lines shift,
# although we aren't adding/removing lines, just modifying them)
files_to_fix = {}
for path, line in errors:
    files_to_fix.setdefault(path, set()).add(line)

for rel_path, line_nums in files_to_fix.items():
    abs_path = os.path.join(project_root, rel_path.replace("/", "\\"))
    if not os.path.exists(abs_path):
        print(f"File not found: {abs_path}")
        continue
        
    print(f"Fixing {abs_path}...")
    with open(abs_path, "r", encoding="utf-8") as f:
        lines = f.readlines()
        
    for l_num in sorted(line_nums, reverse=True):
        idx = l_num - 1
        if idx >= len(lines):
            continue
            
        print(f"  Line {l_num}: {lines[idx].strip()}")
        # Search upwards for 'const '
        fixed = False
        for j in range(idx, max(-1, idx - 15), -1):
            if "const " in lines[j]:
                original = lines[j]
                lines[j] = lines[j].replace("const ", "")
                print(f"    Removed 'const' at line {j+1}: {original.strip()} -> {lines[j].strip()}")
                fixed = True
                break
        
        # If not found j upwards, check if it's on a list literal bracket j like 'const ['
        if not fixed:
            for j in range(idx, max(-1, idx - 15), -1):
                if "const[" in lines[j]:
                    original = lines[j]
                    lines[j] = lines[j].replace("const[", "[")
                    print(f"    Removed 'const' in const[ at line {j+1}: {original.strip()} -> {lines[j].strip()}")
                    fixed = True
                    break
                    
    with open(abs_path, "w", encoding="utf-8", newline="") as f:
        f.writelines(lines)

print("Done automatic fixing!")
