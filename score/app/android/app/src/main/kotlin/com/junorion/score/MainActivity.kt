package com.junorion.score

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Flutter ↔ 네이티브 채보 엔진.
 *  - decode(path, rate, maxSeconds) → Float32List
 *  - transcribe(windows: List<Float32List>) → {note: Float32List, onset: Float32List}
 *  - 진행률은 EventChannel "score/progress" 로 (끝난 창 수)
 */
class MainActivity : FlutterActivity() {
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var model: PitchModel? = null
    private var progressSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        EventChannel(engine.dartExecutor.binaryMessenger, "score/progress").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink) { progressSink = sink }
                override fun onCancel(args: Any?) { progressSink = null }
            })
        MethodChannel(engine.dartExecutor.binaryMessenger, "score/engine").setMethodCallHandler { call, result ->
            when (call.method) {
                "decode" -> worker.execute {
                    try {
                        val pcm = AudioDecoder(this).decode(
                            call.argument<String>("path")!!,
                            call.argument<Int>("rate")!!,
                            call.argument<Double>("maxSeconds")!!)
                        main.post { result.success(pcm) }
                    } catch (e: AudioDecoder.DecodeException) {
                        main.post { result.error("decode", e.message, null) }
                    } catch (e: Exception) {
                        main.post { result.error("decode", "오디오를 읽을 수 없습니다 (${e.javaClass.simpleName})", null) }
                    }
                }
                "transcribe" -> worker.execute {
                    try {
                        val windows = call.argument<List<FloatArray>>("windows")!!
                        val m = model ?: PitchModel(this).also { model = it }
                        val (note, onset) = m.run(windows) { done -> main.post { progressSink?.success(done) } }
                        main.post { result.success(mapOf("note" to note, "onset" to onset)) }
                    } catch (e: Exception) {
                        main.post { result.error("transcribe", e.message ?: e.javaClass.simpleName, null) }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        model?.close()
        worker.shutdown()
        super.onDestroy()
    }
}
