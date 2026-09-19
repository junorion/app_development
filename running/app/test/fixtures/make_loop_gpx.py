"""합성 러닝 GPX 를 만든다 — GPX 재생 통합 테스트용 (지침 11.2).

실제 GPS 오차는 시간에 따라 이어지는(상관된) 오차이므로 AR(1) 잡음으로 흉내 낸다.
진짜 이동 거리는 잡음 없는 경로로 따로 계산해 `expected.json` 에 적는다.

    python3 make_loop_gpx.py   # loop_3km.gpx, loop_3km.expected.json 을 다시 만든다
"""
import json, math, random
from datetime import datetime, timedelta, timezone

random.seed(20260920)
R = 6371008.8
LAT0, LNG0 = 37.5270, 126.9340  # 한강공원 근처 어딘가
T0 = datetime(2026, 9, 20, 6, 30, tzinfo=timezone.utc)

def to_ll(x, y):
    return (LAT0 + math.degrees(y / R), LNG0 + math.degrees(x / (R * math.cos(math.radians(LAT0)))))

# (초, 속도 m/s) 구간. 방향은 완만하게 휘는 곡선.
plan = [(300, 2.8), (240, 3.6), (30, 0.0), (300, 3.2), (120, 4.2), (120, 2.5)]
x = y = 0.0
heading = 0.3
nx = ny = 0.0
rho, sigma = 0.95, 3.0 * math.sqrt(1 - 0.95 ** 2)  # 정상 상태 표준편차 약 3m
true_dist = 0.0
moving_true = 0
pts = []
t = 0
for dur, v in plan:
    for _ in range(dur):
        t += 1
        heading += 0.004 * math.sin(t / 90)
        x += v * math.cos(heading); y += v * math.sin(heading)
        true_dist += v
        if v > 0: moving_true += 1
        nx = rho * nx + random.gauss(0, sigma)
        ny = rho * ny + random.gauss(0, sigma)
        acc = 5.0
        px, py = x + nx, y + ny
        if t in (700, 701):             # 고층 건물 반사: 크게 튄 점
            px += 150
        if 1000 <= t < 1008:            # 터널: 정확도 나쁨
            acc = 60.0
        pts.append((t, px, py, acc))

with open('loop_3km.gpx', 'w') as f:
    f.write('<?xml version="1.0" encoding="UTF-8"?>\n<gpx version="1.1" creator="make_loop_gpx.py" '
            'xmlns="http://www.topografix.com/GPX/1/1">\n<trk><name>합성 3km</name><trkseg>\n')
    for t, px, py, acc in pts:
        lat, lng = to_ll(px, py)
        tm = (T0 + timedelta(seconds=t)).strftime('%Y-%m-%dT%H:%M:%SZ')
        f.write(f'<trkpt lat="{lat:.7f}" lon="{lng:.7f}"><time>{tm}</time><hdop>{acc/5:.1f}</hdop></trkpt>\n')
    f.write('</trkseg></trk></gpx>\n')

with open('loop_3km.expected.json', 'w') as f:
    json.dump({'trueDistanceM': round(true_dist, 1), 'trueMovingSec': moving_true,
               'totalSec': t, 'stopSec': 30}, f, indent=1)
print(round(true_dist, 1), moving_true, len(pts))
