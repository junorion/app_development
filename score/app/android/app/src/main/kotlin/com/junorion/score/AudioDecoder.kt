package com.junorion.score

import android.content.Context
import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.net.Uri
import java.nio.ByteOrder
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.min
import kotlin.math.sin

/** 오디오 파일 → 모노 float (targetRate). 기기 코덱(MediaCodec)이 읽는 형식이면 모두 된다. */
class AudioDecoder(private val context: Context) {

    class DecodeException(message: String) : Exception(message)

    fun decode(source: String, targetRate: Int, maxSeconds: Double): FloatArray {
        val ex = MediaExtractor()
        try {
            if (source.startsWith("content://")) ex.setDataSource(context, Uri.parse(source), null)
            else ex.setDataSource(source)
        } catch (e: Exception) {
            throw DecodeException("파일을 열 수 없습니다")
        }
        val track = (0 until ex.trackCount).firstOrNull {
            ex.getTrackFormat(it).getString(MediaFormat.KEY_MIME)?.startsWith("audio/") == true
        } ?: throw DecodeException("오디오 트랙이 없습니다")
        ex.selectTrack(track)
        val fmt = ex.getTrackFormat(track)
        val mime = fmt.getString(MediaFormat.KEY_MIME)!!
        val codec = MediaCodec.createDecoderByType(mime)
        codec.configure(fmt, null, null, 0)
        codec.start()

        var rate = fmt.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        var channels = fmt.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        var floatPcm = false
        val mono = FloatBuilder()
        val info = MediaCodec.BufferInfo()
        var inputDone = false
        var outputDone = false
        val limit = (maxSeconds * rate).toLong()
        try {
            while (!outputDone) {
                if (!inputDone) {
                    val i = codec.dequeueInputBuffer(10_000)
                    if (i >= 0) {
                        val buf = codec.getInputBuffer(i)!!
                        val n = ex.readSampleData(buf, 0)
                        if (n < 0) {
                            codec.queueInputBuffer(i, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            inputDone = true
                        } else {
                            codec.queueInputBuffer(i, 0, n, ex.sampleTime, 0)
                            ex.advance()
                        }
                    }
                }
                val o = codec.dequeueOutputBuffer(info, 10_000)
                when {
                    o == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        val of = codec.outputFormat
                        rate = of.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                        channels = of.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                        floatPcm = of.containsKey(MediaFormat.KEY_PCM_ENCODING) &&
                            of.getInteger(MediaFormat.KEY_PCM_ENCODING) == AudioFormat.ENCODING_PCM_FLOAT
                    }
                    o >= 0 -> {
                        val buf = codec.getOutputBuffer(o)!!.order(ByteOrder.nativeOrder())
                        buf.position(info.offset)
                        buf.limit(info.offset + info.size)
                        if (floatPcm) {
                            val fb = buf.asFloatBuffer()
                            while (fb.remaining() >= channels) {
                                var s = 0f
                                repeat(channels) { s += fb.get() }
                                mono.add(s / channels)
                            }
                        } else {
                            val sb = buf.asShortBuffer()
                            while (sb.remaining() >= channels) {
                                var s = 0f
                                repeat(channels) { s += sb.get() / 32768f }
                                mono.add(s / channels)
                            }
                        }
                        codec.releaseOutputBuffer(o, false)
                        if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) outputDone = true
                        if (mono.size > limit + rate) throw DecodeException("너무 깁니다 (최대 ${(maxSeconds / 60).toInt()}분)")
                    }
                }
            }
        } finally {
            codec.stop()
            codec.release()
            ex.release()
        }
        if (mono.size == 0) throw DecodeException("소리를 읽지 못했습니다")
        return resample(mono.toArray(), rate, targetRate)
    }

    private class FloatBuilder {
        private var a = FloatArray(1 shl 20)
        var size = 0
            private set

        fun add(v: Float) {
            if (size == a.size) a = a.copyOf(a.size * 2)
            a[size++] = v
        }

        fun toArray(): FloatArray = a.copyOf(size)
    }

    companion object {
        /** Hann 창을 씌운 sinc 보간 리샘플러. 낮출 때는 차단 주파수를 새 나이퀴스트로 내려 겹침(aliasing)을 막는다. */
        fun resample(x: FloatArray, from: Int, to: Int, halfTaps: Int = 16): FloatArray {
            if (from == to) return x
            val ratio = to.toDouble() / from
            val cutoff = min(1.0, ratio)
            val n = floor(x.size * ratio).toInt()
            val out = FloatArray(n)
            val width = halfTaps / cutoff
            for (i in 0 until n) {
                val center = i / ratio
                val lo = maxOf(0, (center - width).toInt())
                val hi = minOf(x.size - 1, (center + width).toInt() + 1)
                var acc = 0.0
                for (j in lo..hi) {
                    val d = (j - center) * cutoff
                    if (abs(d) >= halfTaps) continue
                    val sinc = if (abs(d) < 1e-9) 1.0 else sin(PI * d) / (PI * d)
                    val win = 0.5 + 0.5 * cos(PI * d / halfTaps)
                    acc += x[j] * sinc * win
                }
                out[i] = (acc * cutoff).toFloat()
            }
            return out
        }
    }
}
