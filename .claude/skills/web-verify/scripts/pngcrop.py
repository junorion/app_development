#!/usr/bin/env python3
"""PNG 의 왼쪽 위에서 W×H 만큼 잘라낸다.  python3 pngcrop.py <입력> <출력> <W> <H>"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "app-icon", "scripts"))
from png_resize import read_png, write_png  # noqa: E402

src, dst, W, H = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
w, h, px = read_png(src)
write_png(dst, [row[:min(W, w)] for row in px[:min(H, h)]])
print(f"{dst}: {min(W, w)}x{min(H, h)}")
