import os

errors = [
    ("lib/features/history/screens/weight_history_screen.dart", 53),
    ("lib/features/history/screens/weight_history_screen.dart", 79),
    ("lib/features/history/screens/weight_history_screen.dart", 174),
    ("lib/features/history/screens/weight_history_screen.dart", 176),
    ("lib/features/history/screens/weight_history_screen.dart", 182),
    ("lib/features/history/screens/weight_history_screen.dart", 358),
    ("lib/features/history/screens/weight_history_screen.dart", 375),
    ("lib/features/history/screens/weight_history_screen.dart", 384),
    ("lib/features/history/screens/weight_history_screen.dart", 590),
    ("lib/features/history/screens/weight_history_screen.dart", 600),
    ("lib/features/history/screens/weight_history_screen.dart", 686),
    ("lib/features/history/screens/weight_history_screen.dart", 695),
    ("lib/features/history/screens/weight_history_screen.dart", 708),
    ("lib/features/history/screens/weight_history_screen.dart", 717),
    
    ("lib/features/profile/screens/profile_switcher_screen.dart", 21),
    ("lib/features/profile/screens/profile_switcher_screen.dart", 34),
    ("lib/features/profile/screens/profile_switcher_screen.dart", 132),
    ("lib/features/profile/screens/profile_switcher_screen.dart", 153),
    ("lib/features/profile/screens/profile_switcher_screen.dart", 162),
    ("lib/features/profile/screens/profile_switcher_screen.dart", 172),
    ("lib/features/profile/screens/profile_switcher_screen.dart", 200),
    ("lib/features/profile/screens/profile_switcher_screen.dart", 279),
    ("lib/features/profile/screens/profile_switcher_screen.dart", 329),
    
    ("lib/features/profile/screens/user_details_form_screen.dart", 328),
    ("lib/features/profile/screens/user_details_form_screen.dart", 503),
    ("lib/features/profile/screens/user_details_form_screen.dart", 549),
    ("lib/features/profile/screens/user_details_form_screen.dart", 561),
    ("lib/features/profile/screens/user_details_form_screen.dart", 660),
    
    ("lib/features/settings/screens/settings_screen.dart", 58),
    ("lib/features/settings/screens/settings_screen.dart", 214),
    ("lib/features/settings/screens/settings_screen.dart", 268),
    ("lib/features/settings/screens/settings_screen.dart", 299),
    ("lib/features/settings/screens/settings_screen.dart", 337),
    ("lib/features/settings/screens/settings_screen.dart", 486),
    ("lib/features/settings/screens/settings_screen.dart", 538)
]

# Group by file
files_to_fix = {}
for path, line in errors:
    files_to_fix.setdefault(path, []).append(line)

project_root = r"c:\Project\Assignment\IV_Innovation\assignment"

for rel_path, line_nums in files_to_fix.items():
    abs_path = os.path.join(project_root, rel_path.replace("/", "\\"))
    print(f"Fixing {abs_path}...")
    
    with open(abs_path, "r", encoding="utf-8") as f:
        lines = f.readlines()
        
    for l_num in line_nums:
        # line numbers are 1-based, list is 0-based
        idx = l_num - 1
        if idx < len(lines):
            original = lines[idx]
            # Replace 'const ' with ''
            # Make sure it only replaces the word 'const '
            modified = original.replace("const ", "")
            lines[idx] = modified
            print(f"  Line {l_num}: {original.strip()} -> {modified.strip()}")
            
    with open(abs_path, "w", encoding="utf-8", newline="") as f:
        f.writelines(lines)

print("Done!")
