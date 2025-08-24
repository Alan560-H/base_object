package com.example.flutter_pangrowth.video.view.single_video_card

import android.app.Application
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import android.widget.Toast
import androidx.fragment.app.FragmentActivity
import com.bytedance.sdk.dp.DPSdk
import com.bytedance.sdk.dp.DPWidgetDrawParams
import com.bytedance.sdk.dp.IDPDrawListener
import com.bytedance.sdk.dp.IDPWidget
import com.example.flutter_pangrowth.VideoHolder
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView


/**
 * @Author: gstory
 * @CreateDate: 2021/12/15 12:17 下午
 * @Description: 单视频
 */

internal class VideoSingleCardView(
    var activity: FragmentActivity,
    messenger: BinaryMessenger,
    id: Int,
    params: Map<String?, Any?>
) :
    PlatformView {

    private val TAG = VideoSingleCardView::class.java.simpleName

    private var mContainer: FrameLayout = FrameLayout(activity)
    private var viewWidth: Double = params["viewWidth"] as Double
    private var viewHeight: Double = params["viewHeight"] as Double

    private var dpWidget: IDPWidget? = null

    var isAdded: Boolean = false


    init {
        mContainer.layoutParams?.width = viewWidth.toInt()
        mContainer.layoutParams?.height = viewHeight.toInt()
        if (DPSdk.isStartSuccess()) {
            Log.d(TAG, "dpsdk isStartSuccess")
            init()
        } else {
            VideoHolder.initDpSdk(activity.applicationContext as Application, true);
        }
    }

    private fun init() {
        if (!VideoHolder.isDPStarted) {
            this.view.postDelayed({
                Log.d(TAG, "dpsdk init failed delay")
                init()
            }, 200)
            return
        }
        dpWidget = VideoHolder.buildDrawWidget(
            DPWidgetDrawParams.obtain()
                .adOffset(49) //单位 dp
                .hideClose(false, null)
                .listener(object : IDPDrawListener() {
                    override fun onDPRefreshFinish() {
                        Log.d(TAG, "onDPRefreshFinish")
                    }

                    override fun onDPPageChange(position: Int) {
                        Log.d(TAG, "onDPPageChange: " + position)
                    }

                    override fun onDPVideoPlay(map: MutableMap<String?, Any?>?) {
                        Log.d(TAG, "onDPVideoPlay")
                    }

                    override fun onDPVideoOver(map: MutableMap<String?, Any?>?) {
                        Log.d(TAG, "onDPVideoOver")
                    }

                    override fun onDPClose() {
                        Log.d(TAG, "onDPClose")
                    }

                    override fun onDPReportResult(isSucceed: Boolean) {
                        Log.d(TAG, "onDPReportResult")
                        if (isSucceed) {
                            Toast.makeText(
                                activity,
                                "举报成功",
                                Toast.LENGTH_SHORT
                            ).show()
                        } else {
                            Toast.makeText(
                                activity,
                                "举报失败，请稍后再试",
                                Toast.LENGTH_SHORT
                            ).show()
                        }
                    }
                })
        )
    }

    override fun getView(): View {
        return mContainer
    }

    override fun onFlutterViewAttached(flutterView: View) {
        super.onFlutterViewAttached(flutterView)
        loadVideoSingleCard(flutterView)
    }

    private fun loadVideoSingleCard(flutterView: View) {
        if (isAdded) {
            return
        }
        isAdded = true
        flutterView.post {
            dpWidget?.fragment?.let {
                activity.supportFragmentManager.beginTransaction()
                    .add(flutterView.id, it)
                    .commitAllowingStateLoss()
            }
        }
    }

    override fun dispose() {
        dpWidget?.fragment?.let {
            activity.supportFragmentManager.beginTransaction().remove(it).commitAllowingStateLoss()
        }
        dpWidget?.destroy()
    }
}