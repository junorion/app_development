package com.junorion.score

import android.content.Context
import org.tensorflow.lite.Interpreter
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel

/**
 * Basic Pitch (ICASSP 2022, Spotify, Apache-2.0) TFLite 모델 실행기.
 * 입력: 창 하나 (1, 43844, 1) · 출력: note·onset (1, 172, 88), contour (1, 172, 264) — contour 는 쓰지 않는다.
 * 출력 순서는 PC 에서 확인했다: StatefulPartitionedCall:1 = note, :2 = onset.
 */
class PitchModel(context: Context) : AutoCloseable {
    private val interpreter: Interpreter
    private val noteIdx: Int
    private val onsetIdx: Int
    private val contourIdx: Int

    init {
        val opts = Interpreter.Options().setNumThreads(Runtime.getRuntime().availableProcessors().coerceAtMost(4))
        interpreter = Interpreter(load(context, "nmp.tflite"), opts)
        val names = (0 until interpreter.outputTensorCount).map { interpreter.getOutputTensor(it).name() }
        noteIdx = names.indexOfFirst { it.endsWith(":1") }
        onsetIdx = names.indexOfFirst { it.endsWith(":2") }
        contourIdx = names.indexOfFirst { it.endsWith(":0") }
        require(noteIdx >= 0 && onsetIdx >= 0 && contourIdx >= 0) { "모델 출력 이름이 예상과 다릅니다: $names" }
    }

    /** 창들을 차례로 돌려 note·onset 을 이어 붙인 배열을 돌려준다 (창마다 172×88). */
    fun run(windows: List<FloatArray>, onProgress: (Int) -> Unit = {}): Pair<FloatArray, FloatArray> {
        val frames = OUT_FRAMES * PITCHES
        val note = FloatArray(windows.size * frames)
        val onset = FloatArray(windows.size * frames)
        val input = ByteBuffer.allocateDirect(IN_SAMPLES * 4).order(ByteOrder.nativeOrder())
        val outs = HashMap<Int, Any>()
        val noteBuf = ByteBuffer.allocateDirect(frames * 4).order(ByteOrder.nativeOrder())
        val onsetBuf = ByteBuffer.allocateDirect(frames * 4).order(ByteOrder.nativeOrder())
        val contourBuf = ByteBuffer.allocateDirect(OUT_FRAMES * PITCHES * 3 * 4).order(ByteOrder.nativeOrder())
        outs[noteIdx] = noteBuf
        outs[onsetIdx] = onsetBuf
        outs[contourIdx] = contourBuf
        windows.forEachIndexed { w, samples ->
            require(samples.size == IN_SAMPLES)
            input.rewind()
            input.asFloatBuffer().put(samples)
            noteBuf.rewind(); onsetBuf.rewind(); contourBuf.rewind()
            interpreter.runForMultipleInputsOutputs(arrayOf(input), outs)
            noteBuf.rewind(); onsetBuf.rewind()
            noteBuf.asFloatBuffer().get(note, w * frames, frames)
            onsetBuf.asFloatBuffer().get(onset, w * frames, frames)
            onProgress(w + 1)
        }
        return note to onset
    }

    override fun close() = interpreter.close()

    companion object {
        const val IN_SAMPLES = 43844
        const val OUT_FRAMES = 172
        const val PITCHES = 88

        private fun load(context: Context, name: String): MappedByteBuffer {
            val fd = context.assets.openFd(name) // 압축하지 않은 자산이어야 한다 (build.gradle 의 noCompress)
            FileInputStream(fd.fileDescriptor).use { s ->
                return s.channel.map(FileChannel.MapMode.READ_ONLY, fd.startOffset, fd.declaredLength)
            }
        }
    }
}
