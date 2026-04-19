#!/usr/bin/env python3
"""Verify every <include file="X"/> reference in xml/ matches the actual on-disk filename case.

Case-insensitive filesystems (APFS, Shield FUSE) silently tolerate mismatches; case-sensitive
ones (ext4 on CoreELEC/LibreELEC) do not, producing empty skins. Run before sync to catch drift
the moment it happens instead of after users report broken installs.
"""
import os
import re
import sys

def main(xml_dir: str) -> int:
    if not os.path.isdir(xml_dir):
        print(f"ERROR: not a directory: {xml_dir}")
        return 2

    disk = set(os.listdir(xml_dir))
    disk_lower = {f.lower(): f for f in disk}
    pattern = re.compile(r'<include\s+file="([^"]+)"')

    issues = []
    for f in sorted(disk):
        if not f.lower().endswith(".xml"):
            continue
        path = os.path.join(xml_dir, f)
        try:
            with open(path, "r", encoding="utf-8", errors="ignore") as fh:
                for lineno, line in enumerate(fh, 1):
                    for m in pattern.finditer(line):
                        ref = m.group(1)
                        if ref in disk:
                            continue
                        if ref.lower() in disk_lower:
                            issues.append(
                                f"  CASE MISMATCH {f}:{lineno}  referenced='{ref}'  on-disk='{disk_lower[ref.lower()]}'"
                            )
                        else:
                            issues.append(f"  MISSING {f}:{lineno}  referenced='{ref}'")
        except OSError as e:
            print(f"  READ ERR {path}: {e}")
            return 2

    if issues:
        print("ERROR: include filename case drift detected — would break case-sensitive filesystems (CoreELEC/LibreELEC):")
        for i in issues:
            print(i)
        return 1

    print("check_case: ok")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else "xml"))
