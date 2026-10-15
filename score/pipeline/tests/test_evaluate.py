import pretty_midi

from scoreapp.evaluate import crop, load_reference, score
from scoreapp.notes import Note


def test_perfect_and_empty():
    ref = [Note(0.0, 0.5, 60), Note(0.5, 1.0, 64)]
    assert score(ref, ref).onset_f1 == 1.0 and score(ref, ref).offset_f1 == 1.0
    assert score(ref, []).onset_f1 == 0.0


def test_wrong_pitch_and_late_onset_miss():
    ref = [Note(0.0, 0.5, 60), Note(0.5, 1.0, 64)]
    est = [Note(0.0, 0.5, 61), Note(0.58, 1.0, 64)]  # 반음 틀림, 80ms 늦음
    assert score(ref, est).onset_f1 == 0.0


def test_offset_counts_only_in_offset_metric():
    ref = [Note(0.0, 1.0, 60)]
    est = [Note(0.0, 0.3, 60)]
    s = score(ref, est)
    assert s.onset_f1 == 1.0 and s.offset_f1 == 0.0


def test_pedal_extends_until_release_or_restrike(tmp_path):
    pm = pretty_midi.PrettyMIDI()
    inst = pretty_midi.Instrument(0)
    inst.notes += [pretty_midi.Note(80, 60, 0.0, 0.2), pretty_midi.Note(80, 64, 0.5, 0.6),
                   pretty_midi.Note(80, 60, 1.0, 1.2)]
    inst.control_changes += [pretty_midi.ControlChange(64, 127, 0.1), pretty_midi.ControlChange(64, 0, 2.0)]
    pm.instruments.append(inst)
    p = tmp_path / "p.mid"
    pm.write(str(p))
    ends = {(n.pitch, round(n.onset, 2)): round(n.offset, 2) for n in load_reference(p)}
    assert ends[(60, 0.0)] == 1.0   # 페달로 이어지다 같은 음을 다시 쳐서 끝
    assert ends[(64, 0.5)] == 2.0   # 페달을 뗄 때까지
    assert ends[(60, 1.0)] == 2.0
    assert len(load_reference(p, pedal=False)) == 3


def test_crop():
    ns = [Note(0.0, 5.0, 60), Note(9.0, 12.0, 62), Note(11.0, 12.0, 64)]
    assert [(n.onset, n.offset) for n in crop(ns, 10)] == [(0.0, 5.0), (9.0, 10.0)]
