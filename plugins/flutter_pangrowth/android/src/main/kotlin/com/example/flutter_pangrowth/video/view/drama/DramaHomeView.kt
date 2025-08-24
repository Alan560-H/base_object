package com.example.flutter_pangrowth.video.view.drama

import android.util.Log
import android.view.View
import android.widget.FrameLayout
import androidx.fragment.app.FragmentActivity
import com.bytedance.sdk.djx.DJXSdk
import com.bytedance.sdk.djx.IDJXWidget
import com.bytedance.sdk.djx.interfaces.listener.IDJXDramaHomeListener
import com.bytedance.sdk.djx.interfaces.listener.IDJXDramaUnlockListener
import com.bytedance.sdk.djx.model.DJXDrama
import com.bytedance.sdk.djx.model.DJXDramaDetailConfig
import com.bytedance.sdk.djx.model.DJXDramaUnlockAdMode
import com.bytedance.sdk.djx.params.DJXWidgetDramaHomeParams
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView

internal class DramaHomeView(
    var activity: FragmentActivity,
    messenger: BinaryMessenger,
    id: Int,
    params: Map<String?, Any?>
) : PlatformView {


    private val TAG = DramaHomeView::class.java.simpleName

    private var mContainer: FrameLayout? = null
    private var viewWidth: Double = params["viewWidth"] as Double
    private var viewHeight: Double = params["viewHeight"] as Double

    private var dpWidget: IDJXWidget? = null

    private var isAdded = false

    companion object {

        const val FREE_SET = 5
    }

    init {
        Log.d(TAG, "init")
        //初始化 grid 组件
        mContainer = FrameLayout(activity)
        mContainer?.layoutParams?.width = viewWidth.toInt()
        mContainer?.layoutParams?.height = viewHeight.toInt()
        Log.d(TAG, "height $viewHeight width $viewWidth")
        initDrawWidget()
    }

    private fun initDrawWidget() {
        if (DJXSdk.isStartSuccess()) {
            init()
        }
    }

    private fun init() {
        Log.d(TAG, "init d")

        val detailConfig = DJXDramaDetailConfig.obtain(
            DJXDramaUnlockAdMode.MODE_COMMON,
            FREE_SET,
            object : IDJXDramaUnlockListener {
                override fun unlockFlowEnd(
                    drama: DJXDrama,
                    errCode: IDJXDramaUnlockListener.UnlockErrorStatus?,
                    map: Map<String, Any>?
                ) {

                }

                override fun unlockFlowStart(
                    drama: DJXDrama,
                    callback: IDJXDramaUnlockListener.UnlockCallback,
                    map: Map<String, Any>?
                ) {

                }
            }
        ).hideBack(true, null).hideTopInfo(true)
        dpWidget = DJXSdk.factory().createDramaHome(
            DJXWidgetDramaHomeParams.obtain(detailConfig)
                .setTopOffset(30)
                .listener(object : IDJXDramaHomeListener() {
                    override fun onItemClick(drama: DJXDrama?, map: MutableMap<String, Any>?) {
                        super.onItemClick(drama, map)
                        drama ?: return
                        map ?: return
                    }
                })
        )

        Log.d(TAG, "init dpWidget $dpWidget")

    }


    override fun getView(): View {
        Log.d(TAG, "getView")
        return mContainer!!
    }

    override fun onFlutterViewAttached(flutterView: View) {
        super.onFlutterViewAttached(flutterView)
        Log.d(
            TAG,
            "flutterView $flutterView container $mContainer add fragment ${dpWidget?.fragment}"
        )
        if (isAdded) {
            return
        }
        isAdded = true
        flutterView.post {
            dpWidget?.fragment?.let {
                activity.supportFragmentManager.beginTransaction()
                    .add(flutterView.id, it, "drama_home")
                    .commitAllowingStateLoss()
            }
        }
    }

    override fun dispose() {
        Log.d(TAG, "dispose container $mContainer remove ${dpWidget?.fragment}")
        dpWidget?.fragment?.let {
            activity.supportFragmentManager.beginTransaction().remove(it).commitAllowingStateLoss()
        }
        dpWidget?.destroy()
    }

}