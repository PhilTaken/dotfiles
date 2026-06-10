#!/usr/bin/env python3
"""
# Usage

Add to .git/config:

```
[merge "batou-secret"]
    name = merge driver for batou secrets
    driver = /path/to/batou-merge.py %O %A %B %P
    recursive = binary
```

And in .gitattributes:

```
secrets.cfg.age merge=batou-secret
secrets.cfg.age-diffable merge=batou-secret
```
"""

import configparser
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import batou
from batou.environment import Environment


def decrypt(path: str, suffix: str) -> str:
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        tmp_path = tmp.name
        with open(path, "rb") as src:
            tmp.write(src.read())

    try:
        result = subprocess.run(
            ["batou", "secrets", "decrypttostdout", tmp_path],
            capture_output=True,
            check=True,
        )
    finally:
        os.unlink(tmp_path)

    return result.stdout.decode("utf-8")


def merge_text(current: str, base: str, other: str) -> str:
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)

        current_file = tmp / "current"
        base_file = tmp / "base"
        other_file = tmp / "other"

        current_file.write_text(current)
        base_file.write_text(base)
        other_file.write_text(other)

        result = subprocess.run(
            [
                "git",
                "merge-file",
                str(current_file),
                str(base_file),
                str(other_file),
            ],
            capture_output=True,
            text=True,
        )

        if result.returncode != 0:
            raise RuntimeError("Merge conflict detected, aborting")

        return current_file.read_text()


def main() -> int:
    if len(sys.argv) < 4:
        print(
            "Usage: batou-merge.py <ancestor> <ours> <theirs> [path]",
            file=sys.stderr,
        )
        return 128

    ancestor_file = sys.argv[1]
    ours_file = sys.argv[2]  # write result back here
    theirs_file = sys.argv[3]
    repo_path = sys.argv[4] if len(sys.argv) > 4 else ours_file

    suffixes = Path(repo_path).suffixes
    suffix = "".join(suffixes)

    try:
        base_text = decrypt(ancestor_file, suffix)
        ours_text = decrypt(ours_file, suffix)
        theirs_text = decrypt(theirs_file, suffix)
    except Exception as exc:
        print(
            f"failed to decrypt secrets, check if batou is in your PATH: {exc}",
            file=sys.stderr,
        )
        return 128

    try:
        merged_text = merge_text(ours_text, base_text, theirs_text)
    except Exception as exc:
        print(f"merging secrets failed: {exc}", file=sys.stderr)
        return 128

    # reencrypt
    environment_name = repo_path.split("/")[1]
    environment = Environment(environment_name)
    environment.load_secrets()
    cl = type(environment.secret_provider.config_file)
    with cl(Path(ours_file), writeable=True) as encryptedfile:
        environment.secret_provider.write_file(
            encryptedfile, merged_text.encode("utf-8")
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
