package com.junorion.running

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTimestamp
import android.media.AudioTrack
import android.os.Process
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.exp
import kotlin.math.sin

/**
 * 프레임 수로 박자를 배치하는 메트로놈 (지침 6.1).
 *
 * 타이머로 "지금 울려라"를 부르지 않는다. 오디오 스트림에 PCM 을 계속 써 넣으면서, 박자가 들어갈
 * 프레임 위치(샘플레이트 × 60 ÷ spm 간격, 배정밀도 누적)에 틱 소리를 섞는다. 그래서 틱 간격은
 * 구조적으로 정확하고, 어긋날 수 있는 경우는 버퍼를 제때 못 채워 소리가 끊기는 것(underrun)뿐이다.
 * 그 횟수와 출력 시계의 어긋남을 [stats] 로 보고한다.
 *
 * 오디오 포커스를 요청하지 않는다 — 다른 앱 음악과 섞여 재생된다 (지침 6.4).
 */
class Metronome {
    private val sr = 48000
    private val bufFrames = 480 // 10ms
    @Volatile private var spm = 170.0
    @Volatile private var volume = 0.8f
    @Volatile private var running = false
    private var thread: Thread? = null
    private var track: AudioTrack? = null

    // 틱(높은 음)과 톡(낮은 음)을 번갈아 — 날카롭지 않은 나무 소리 계열 (지침 6.1)
    private val tick = click(1600.0, 0.030)
    private val tock = click(1100.0, 0.030)

    @Volatile private var ticks = 0L
    @Volatile private var framesWritten = 0L
    @Volatile private var maxClockDevMs = 0.0
    @Volatile private var startedAtNs = 0L
    private var tsBaseFrame = -1L
    private var tsBaseNs = 0L

    private fun click(freq: Double, sec: Double): FloatArray {
        val n = (sr * sec).toInt()
        return FloatArray(n) { i ->
            val t = i.toDouble() / sr
            // 짧은 어택 + 지수 감쇠. 2배음을 약하게 섞어 나무를 두드린 느낌을 낸다.
            val env = (1 - exp(-t * 2000)) * exp(-t * 140)
            (env * (sin(2 * PI * freq * t) + 0.35 * sin(2 * PI * freq * 2.01 * t)) * 0.6).toFloat()
        }
    }

    fun setSpm(v: Double) { spm = v.coerceIn(100.0, 220.0) }
    fun setVolume(v: Double) { volume = v.toFloat().coerceIn(0f, 1f) }

    @Synchronized
    fun start() {
        if (running) return
        val minBuf = AudioTrack.getMinBufferSize(sr, AudioFormat.CHANNEL_OUT_MONO, AudioFormat.ENCODING_PCM_FLOAT)
        val t = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setSampleRate(sr)
                    .setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build()
            )
            .setBufferSizeInBytes(maxOf(minBuf, bufFrames * 4 * 4))
            .setTransferMode(AudioTrack.MODE_STREAM)
            .setPerformanceMode(AudioTrack.PERFORMANCE_MODE_LOW_LATENCY)
            .build()
        track = t
        ticks = 0; framesWritten = 0; maxClockDevMs = 0.0; tsBaseFrame = -1
        startedAtNs = System.nanoTime()
        running = true
        t.play()
        thread = Thread({ loop(t) }, "metronome").also { it.start() }
    }

    @Synchronized
    fun stop() {
        running = false
        thread?.join(500)
        thread = null
        track?.let { it.stop(); it.release() }
        track = null
    }

    private fun loop(t: AudioTrack) {
        Process.setThreadPriority(Process.THREAD_PRIORITY_URGENT_AUDIO)
        val buf = FloatArray(bufFrames)
        var frame = 0L // 지금 버퍼의 첫 프레임 번호
        var nextBeat = 0.0 // 다음 박자의 프레임 위치 (배정밀도 — 소수점 오차가 쌓이지 않는다)
        var beatIdx = 0L
        var playing: FloatArray? = null
        var playPos = 0
        val ts = AudioTimestamp()
        while (running) {
            java.util.Arrays.fill(buf, 0f)
            val end = frame + bufFrames
            var i = 0
            while (i < bufFrames) {
                val f = frame + i
                if (f >= nextBeat) {
                    playing = if (beatIdx % 2 == 0L) tick else tock
                    playPos = 0
                    beatIdx++
                    ticks = beatIdx
                    // 간격은 매 박자 새로 읽는다 — 값을 바꾸면 위상을 유지한 채 다음 박자부터 반영
                    nextBeat += sr * 60.0 / spm
                }
                val p = playing
                if (p != null) {
                    buf[i] = p[playPos] * volume
                    playPos++
                    if (playPos >= p.size) playing = null
                }
                i++
            }
            val w = t.write(buf, 0, bufFrames, AudioTrack.WRITE_BLOCKING)
            if (w < 0) break
            frame = end
            framesWritten = end
            // 출력 시계 점검: 재생된 프레임 수와 시스템 시계가 같은 속도로 가는지
            if (t.getTimestamp(ts)) {
                if (tsBaseFrame < 0 && ts.framePosition > sr) {
                    tsBaseFrame = ts.framePosition; tsBaseNs = ts.nanoTime
                } else if (tsBaseFrame >= 0) {
                    val expectNs = tsBaseNs + (ts.framePosition - tsBaseFrame) * 1_000_000_000L / sr
                    val dev = abs(ts.nanoTime - expectNs) / 1e6
                    if (dev > maxClockDevMs) maxClockDevMs = dev
                }
            }
        }
    }

    fun stats(): Map<String, Any> {
        val t = track
        return mapOf(
            "running" to running,
            "ticks" to ticks,
            "underruns" to (t?.underrunCount ?: 0),
            "seconds" to framesWritten.toDouble() / sr,
            "maxClockDevMs" to maxClockDevMs,
            "spm" to spm,
        )
    }
}
