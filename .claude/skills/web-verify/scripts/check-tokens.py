#!/usr/bin/env python3
"""CSS 토큰·색 값 점검. 브라우저는 틀린 값을 조용히 무시하므로 커밋 전에 돌린다.

    python3 check-tokens.py index.html

- var(--x) 로 쓰는데 어디에서도 정의하지 않은 토큰
- 정의만 하고 쓰지 않는 토큰 (경고)
- 형식이 틀린 # 색 값 (#5a6party 같은 편집 오타)
라이트/다크 중 한쪽 테마에만 정의된 토큰도 찾는다 — 테마를 바꾸면 그 색만 안 바뀐다.
"""
import re
import sys

src = open(sys.argv[1], encoding="utf-8").read()
# <style> 블록과 style="" 속성만 CSS 로 본다. 토큰 정의는 JS 의 setProperty 로도 생긴다.
css = "\n".join(re.findall(r"<style[^>]*>([\s\S]*?)</style>", src)
                + [v + ";" for v in re.findall(r"\sstyle=\"([^\"]*)\"", src)])

defined = set(re.findall(r"(--[\w-]+)\s*:", css)) | set(re.findall(r"setProperty\(\s*[\"'](--[\w-]+)", src))
used = set(re.findall(r"var\(\s*(--[\w-]+)", src)) | set(re.findall(r"setProperty\(\s*[\"'](--[\w-]+)", src))
bad = 0

for t in sorted(used - defined):
    print(f"정의되지 않은 토큰: {t}"); bad += 1
for t in sorted(defined - used):
    print(f"(경고) 쓰지 않는 토큰: {t}")

# 테마 블록 비교: 선택자에 맨 :root 가 들어 있는 블록이 기본, 나머지 :root[...] 가 테마.
blocks = re.findall(r"(:root[^{]*)\{([^}]*)\}", css)
base, themes = set(), {}
for sel, body in blocks:
    toks = set(re.findall(r"(--[\w-]+)\s*:", body))
    if ":root" in [x.strip() for x in sel.split(",")]:
        base |= toks
    else:
        themes.setdefault(sel.strip(), set()).update(toks)
for sel, toks in themes.items():
    for t in sorted(toks - base):
        print(f"(경고) {sel} 에만 정의된 토큰: {t} — 다른 테마에서는 fallback 이 쓰인다")

# 색 값은 CSS 선언의 값(prop: value)과 SVG 색 속성에서만 본다 — #id 선택자·url(#id) 는 제외.
HEX = re.compile(r"#[0-9a-fA-F]{3,4}|#[0-9a-fA-F]{6}|#[0-9a-fA-F]{8}")
values = [v for _, v in re.findall(r"([\w-]+)\s*:\s*([^;{}]+)(?=[;}])", css)]
values += re.findall(r"(?:fill|stroke|stop-color|color|flood-color)=[\"']([^\"']+)", src)
seen = set()
for v in values:
    for m in re.finditer(r"(?<![\w(])#[0-9A-Za-z]+\b", v):
        h = m.group(0)
        if not HEX.fullmatch(h) and h not in seen:
            seen.add(h); print(f"잘못된 색 값: {h}  ({v.strip()[:40]})"); bad += 1

print("문제 없음" if not bad else f"{bad}건")
sys.exit(1 if bad else 0)
