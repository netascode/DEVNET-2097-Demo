# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Daniel Schmidt <danischm@cisco.com>

import os

VALIDATION_OUTPUT = """\n**Validation Errors**
```
"""

TEST_OUTPUT = """\n[**Testing**](https://netascode.github.io/DEVNET-2097-Demo/log.html)
```
"""

if __name__ == "__main__":
    validation_lines = None
    test_lines = None
    if os.path.isfile("./validate_output.txt"):
        with open("./validate_output.txt", "r") as file:
            validation_output = file.read()
            if len(validation_output.strip()):
                validation_lines = VALIDATION_OUTPUT + validation_output + "\n```\n"
    if os.path.isfile("./test_output.txt"):
        with open("./test_output.txt", "r") as in_file:
            tests = in_file.read()
        for line in tests.split("\n"):
            if "tests, " in line:
                test_lines = line
        if test_lines:
            test_lines = TEST_OUTPUT + test_lines[0:-1] + "\n```\n"
    if validation_lines:
        print(validation_lines)
    if test_lines:
        print(test_lines)
