#!/usr/bin/env python3

import sys

if len(sys.argv) < 2:
    print("At least one argument is required")
    exit(1)

for link in sys.argv[1::]:
    print(link.replace("zpl://", "https://app.zeplin.io/").replace("screen?pid=", "project/").replace("&sid=", "/screen/"))
