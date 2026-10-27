#!/usr/bin/env python3
"""PNG 를 RGBA(32비트)로 다시 쓰고 원하는 크기로 줄인다. 외부 라이브러리 없이 zlib/struct 만 쓴다.

    python3 png_resize.py <입력.png> <출력.png> <한 변 px>

- 입력: 8비트 RGB/RGBA, 인터레이스 없음 (헤드리스 Chrome 스크린샷이 이 형식이다)
- 출력: 항상 RGBA — Play 스토어는 512 아이콘에 알파 채널이 있는 32비트 PNG 를 요구한다
- 축소는 면적 평균이라 192px 로 줄여도 계단이 지지 않는다
"""
import struct
import sys
import zlib


def read_png(path):
    data = open(path, "rb").read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        sys.exit(f"PNG 가 아닙니다: {path}")
    pos, idat = 8, b""
    while pos < len(data):
        n, kind = struct.unpack(">I4s", data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + n]
        if kind == b"IHDR":
            w, h, depth, ctype, _, _, interlace = struct.unpack(">IIBBBBB", body)
        elif kind == b"IDAT":
            idat += body
        pos += 12 + n
    if depth != 8 or ctype not in (2, 6) or interlace:
        sys.exit(f"지원하지 않는 형식: depth={depth} color={ctype} interlace={interlace}")
    bpp = 3 if ctype == 2 else 4
    raw = zlib.decompress(idat)
    stride = w * bpp
    rows, prev, i = [], bytearray(stride), 0
    for _ in range(h):
        f = raw[i]; line = bytearray(raw[i + 1:i + 1 + stride]); i += 1 + stride
        for x in range(stride):
            a = line[x - bpp] if x >= bpp else 0
            b = prev[x]
            c = prev[x - bpp] if x >= bpp else 0
            if f == 1: line[x] = (line[x] + a) & 255
            elif f == 2: line[x] = (line[x] + b) & 255
            elif f == 3: line[x] = (line[x] + (a + b) // 2) & 255
            elif f == 4:
                p = a + b - c; pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                line[x] = (line[x] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        rows.append(line); prev = line
    px = [[tuple(r[x * bpp:x * bpp + bpp]) + ((255,) if bpp == 3 else ()) for x in range(w)] for r in rows]
    return w, h, px


def resize(w, h, px, size):
    out = []
    for oy in range(size):
        y0, y1 = oy * h / size, (oy + 1) * h / size
        row = []
        for ox in range(size):
            x0, x1 = ox * w / size, (ox + 1) * w / size
            acc, tot = [0.0] * 4, 0.0
            for y in range(int(y0), min(h, int(y1 + 0.999))):
                wy = min(y + 1, y1) - max(y, y0)
                for x in range(int(x0), min(w, int(x1 + 0.999))):
                    wt = wy * (min(x + 1, x1) - max(x, x0))
                    p = px[y][x]
                    for k in range(4): acc[k] += p[k] * wt
                    tot += wt
            row.append(tuple(round(v / tot) for v in acc))
        out.append(row)
    return out


def write_png(path, px):
    h, w = len(px), len(px[0])
    raw = b"".join(b"\x00" + bytes(c for p in row for c in p) for row in px)
    def chunk(kind, body):
        return struct.pack(">I", len(body)) + kind + body + struct.pack(">I", zlib.crc32(kind + body))
    png = (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))
    open(path, "wb").write(png)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    src, dst, size = sys.argv[1], sys.argv[2], int(sys.argv[3])
    w, h, px = read_png(src)
    write_png(dst, px if (w, h) == (size, size) else resize(w, h, px, size))
    print(f"{dst}: {size}x{size} RGBA")
