package com.example.flutter_pangrowth.video.view.drama

import android.app.Activity
import android.app.AlertDialog
import android.content.DialogInterface
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import android.widget.Toast
import androidx.fragment.app.FragmentActivity
import com.blankj.utilcode.util.ActivityUtils
import com.bytedance.sdk.djx.DJXRewardAdResult
import com.bytedance.sdk.djx.DJXSdk
import com.bytedance.sdk.djx.IDJXWidget
import com.bytedance.sdk.djx.interfaces.listener.IDJXDramaHomeListener
import com.bytedance.sdk.djx.interfaces.listener.IDJXDramaUnlockListener
import com.bytedance.sdk.djx.model.DJXDrama
import com.bytedance.sdk.djx.model.DJXDramaDetailConfig
import com.bytedance.sdk.djx.model.DJXDramaUnlockAdMode
import com.bytedance.sdk.djx.model.DJXDramaUnlockInfo
import com.bytedance.sdk.djx.model.DJXDramaUnlockMethod
import com.bytedance.sdk.djx.model.DJXUnlockModeType
import com.bytedance.sdk.djx.params.DJXWidgetDramaHomeParams
import com.bytedance.sdk.openadsdk.AdSlot
import com.bytedance.sdk.openadsdk.TTAdLoadType
import com.bytedance.sdk.openadsdk.TTAdNative
import com.bytedance.sdk.openadsdk.TTAdSdk
import com.bytedance.sdk.openadsdk.TTRewardVideoAd
import com.bytedance.sdk.openadsdk.TTRewardVideoAd.RewardAdInteractionListener
import com.example.flutter_pangrowth.Channel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import java.util.Locale

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

    private var isRewardArrived = false

    companion object {

        const val FREE_SET = 5

        const val LOCK_SET = 1

        const val ON_UNLOCK_METHOD = "on_unlock_method"

        //连续解锁开启
        const val enableContinuesUnlock: Boolean = false
    }

    init {
        Log.d(TAG, "init")
        //初始化 grid 组件
        mContainer = FrameLayout(activity).apply {
            this.id = View.generateViewId()
            layoutParams?.width = viewWidth.toInt()
            layoutParams?.height = viewHeight.toInt()
        }
        Log.d(TAG, "height $viewHeight width $viewWidth")
        initDrawWidget()
    }

    private fun initDrawWidget() {
        if (DJXSdk.isStartSuccess()) {
            init()
        }
    }

    private fun init() {
        Log.d(TAG, "init dj sdk start")

        val detailConfig = DJXDramaDetailConfig.obtain(
            DJXDramaUnlockAdMode.MODE_COMMON,
            FREE_SET,
            object : IDJXDramaUnlockListener {
                override fun unlockFlowEnd(
                    drama: DJXDrama,
                    errCode: IDJXDramaUnlockListener.UnlockErrorStatus?,
                    map: Map<String, Any>?
                ) {
                    Log.d(TAG, "unlockFlowEnd errCode $errCode")
                }

                override fun unlockFlowStart(
                    drama: DJXDrama,
                    callback: IDJXDramaUnlockListener.UnlockCallback,
                    map: Map<String, Any>?
                ) {
                    // 解锁支持多种方式：支付、广告。根据业务需求自行定义
                    // 如果在其他时机已经购买会员可以设置 unlockInfo 中的 hasMember 为 true
                    // val info = DJXDramaUnlockInfo(drama.id, lockSet, DJXDramaUnlockMethod.METHOD_PAY_MEMBER, true)
                    // callback.onConfirm(info)

                    val topActivity = ActivityUtils.getTopActivity()

                    if (enableContinuesUnlock) {
                        showContinuesDialog(
                            topActivity,
                            LOCK_SET,
                            drama,
                            callback,
                            map,
                            drama.index,
                            drama.index + 1
                        )
                    } else {
                        //demo仅演示广告解锁
                        UnlockDialog(topActivity).apply {
                            setListener(
                                ad = {
                                    val unlockType =
                                        if (enableContinuesUnlock) DJXUnlockModeType.UNLOCKTYPE_CONTINUES else DJXUnlockModeType.UNLOCKTYPE_DEFAULT
                                    //点击激励视频解锁
                                    val info = DJXDramaUnlockInfo(
                                        drama.id,
                                        LOCK_SET,
                                        DJXDramaUnlockMethod.METHOD_AD,
                                        false,
                                        unlockType = unlockType
                                    )

                                    Channel.methodChannel.invokeMethod(ON_UNLOCK_METHOD, true)
                                    callback.onConfirm(info)
                                },
                                close = {
                                    hide()
                                    val info = DJXDramaUnlockInfo(
                                        drama.id,
                                        LOCK_SET,
                                        DJXDramaUnlockMethod.METHOD_AD,
                                        cancelUnlock = true
                                    )
                                    Channel.methodChannel.invokeMethod(ON_UNLOCK_METHOD, false)
                                    callback.onConfirm(info)
                                }
                            )
                            show()
                        }
                    }

                }

                override fun showCustomAd(
                    drama: DJXDrama,
                    callback: IDJXDramaUnlockListener.CustomAdCallback
                ) {
//                    super.showCustomAd(drama, callback)
                    showAdDefault(callback)
                }
            }
        )
        dpWidget = DJXSdk.factory().createDramaHome(
            DJXWidgetDramaHomeParams.obtain(detailConfig)
                .also {
                    it.mShowBackBtn = false
                    it.mShowPageTitle = false
                }
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

    private fun showContinuesDialog(
        activity: Activity,
        lockSet: Int,
        drama: DJXDrama,
        callback: IDJXDramaUnlockListener.UnlockCallback,
        map: Map<String, Any>?,
        startIndex: Int,// 开始解锁的集数
        endIndex: Int?// 最新解锁的集数
    ) {
        val builder: AlertDialog.Builder = AlertDialog.Builder(activity)
        val tips = if (lockSet == 1) String.format(
            Locale.getDefault(),
            "您已解锁第%d集",
            startIndex,
            startIndex + lockSet - 1
        ) else {
            String.format(
                Locale.getDefault(),
                "您已解锁第%d-%d集",
                startIndex,
                startIndex + lockSet - 1
            )
        }
        if (endIndex == null) return
        val string = if (lockSet == 1) String.format(
            Locale.getDefault(),
            "再解锁第%d集",
            endIndex,
            endIndex + lockSet - 1
        ) else {
            String.format(Locale.getDefault(), "再解锁%d-%d集", endIndex, endIndex + lockSet - 1)
        }
        builder.setMessage(tips)
            .setCancelable(false)
            .setPositiveButton(string, DialogInterface.OnClickListener { dialog, id ->
                val info = DJXDramaUnlockInfo(
                    drama.id,
                    lockSet,
                    DJXDramaUnlockMethod.METHOD_AD,
                    false,
                    unlockType = DJXUnlockModeType.UNLOCKTYPE_CONTINUES
                )
                callback.onConfirm(info)
            })
            .setNegativeButton("关闭弹窗", DialogInterface.OnClickListener { dialog, id -> // 执行否的操作
                val info = DJXDramaUnlockInfo(
                    drama.id,
                    lockSet,
                    DJXDramaUnlockMethod.METHOD_AD,
                    false,
                    null,
                    true
                )
                callback.onConfirm(info)
                dialog.cancel()
            })

        val alert: AlertDialog = builder.create()
        alert.show()
    }

    private fun showAdDefault(callback: IDJXDramaUnlockListener.CustomAdCallback) {
        val adSlot = AdSlot.Builder()
            .setCodeId("953685911") // 广告代码位Id
            .setAdLoadType(TTAdLoadType.LOAD) // 本次广告用途：TTAdLoadType.LOAD实时；TTAdLoadType.PRELOAD预请求
            .build()

        TTAdSdk.getAdManager().createAdNative(activity)
            .loadRewardVideoAd(adSlot, object : TTAdNative.RewardVideoAdListener {
                override fun onError(p0: Int, p1: String?) {
                    callback.onError()
                }

                override fun onRewardVideoAdLoad(ad: TTRewardVideoAd?) {
                    ad?.apply {
                        setRewardAdInteractionListener(object : RewardAdInteractionListener {
                            override fun onAdShow() {
                                Toast.makeText(activity, "自定义广告展示", Toast.LENGTH_LONG).show()
                                callback.onShow("") // CSJ cpm 不对外，可以参考 GroMore getShowEcpm 方法获取
                            }

                            override fun onAdVideoBarClick() {
                                // 广告点击
                            }

                            override fun onAdClose() {
                                // 广告关闭
                            }

                            override fun onVideoComplete() {
                                // 广告素材播放完成，例如视频未跳过，完整的播放了
                            }

                            override fun onVideoError() {
                                // 广告展示时出错
                                callback.onRewardVerify(DJXRewardAdResult(false))
                            }

                            override fun onRewardVerify(
                                rewardVerify: Boolean,
                                rewardAmount: Int,
                                rewardName: String,
                                errorCode: Int,
                                errorMsg: String
                            ) {
                                // 已废弃 请使用 onRewardArrived 替代
                            }

                            override fun onRewardArrived(
                                isRewardValid: Boolean,
                                rewardType: Int,
                                extraInfo: Bundle
                            ) {
                                val result = DJXRewardAdResult(isRewardValid)
                                isRewardArrived = isRewardValid
                                callback.onRewardVerify(result)
                            }

                            override fun onSkippedVideo() {
                                // 用户在观看时点击了跳过
                                if (!isRewardArrived) {
                                    callback.onRewardVerify(DJXRewardAdResult(false))
                                }
                            }
                        })
                        showRewardVideoAd(activity)
                    }
                }

                override fun onRewardVideoCached() {

                }

                override fun onRewardVideoCached(p0: TTRewardVideoAd?) {
                }
            })
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
        mContainer?.post {
            dpWidget?.fragment?.let {
                activity.supportFragmentManager.beginTransaction()
                    .add(mContainer!!.id, it, "drama_home")
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

