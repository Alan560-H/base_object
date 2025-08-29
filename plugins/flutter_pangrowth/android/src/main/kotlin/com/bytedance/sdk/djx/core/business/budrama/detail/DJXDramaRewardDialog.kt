//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//
package com.bytedance.sdk.djx.core.business.budrama.detail

import android.app.Dialog
import android.content.Context
import android.os.Bundle
import android.view.View
import android.widget.TextView
import com.pangle.cn.pangrowth.djx.sdk.lite.R.id
import com.pangle.cn.pangrowth.djx.sdk.lite.R.layout
import com.pangle.cn.pangrowth.djx.sdk.lite.R.style
import java.util.Locale

class DJXDramaRewardDialog(
    var1: Context,
    private val mLockSet: Int,
    private val mHasTips: Boolean
) : Dialog(var1, style.djx_draw_share_dialog_style) {
    private var mOnDramaRewardDialogListener: OnDramaRewardDialogListener? = null

    fun setOnDramaRewardDialogListener(var1: OnDramaRewardDialogListener?) {
        this.mOnDramaRewardDialogListener = var1
    }

    override fun onCreate(var1: Bundle?) {
        super.onCreate(var1)
        this.setContentView(layout.djx_drama_reward_dialog_layout)
        if (this.getWindow() != null) {
            try {
                this.getWindow()!!.setWindowAnimations(style.djx_animation_share_style)
            } catch (var3: Throwable) {
            }
        }

        this.setCanceledOnTouchOutside(false)
        this.setCancelable(false)
        this.initView()
    }

    fun initView() {
        val var1 = this.findViewById<View?>(id.djx_drama_unlock_desc) as TextView
        var var2 = String.format(Locale.getDefault(), "看激励视频解锁下%d集剧情", this.mLockSet)
        if (this.mHasTips) {
            var2 = var2 + "\n请按照顺序解锁"
        }

        var1.setText(var2)
        this.findViewById<View?>(id.djx_drama_show_reward)
            .setOnClickListener(object : View.OnClickListener {
                override fun onClick(var1: View?) {
                    if (this@DJXDramaRewardDialog.mOnDramaRewardDialogListener != null) {
                        this@DJXDramaRewardDialog.mOnDramaRewardDialogListener!!.onConfirm()
                    }
                }
            })
        this.findViewById<View?>(id.djx_drama_leave_reward)
            .setOnClickListener(object : View.OnClickListener {
                override fun onClick(var1: View?) {
                    if (this@DJXDramaRewardDialog.mOnDramaRewardDialogListener != null) {
                        this@DJXDramaRewardDialog.mOnDramaRewardDialogListener!!.onCancel()
                    }
                }
            })
    }

    override fun show() {
        super.show()
        if (this.getWindow() != null) {
            try {
                val var1 = this.getWindow()!!.getAttributes()
                var1.gravity = 80
                var1.width = -1
                var1.height = -1
                this.getWindow()!!.getDecorView().setPadding(0, 0, 0, 0)
                this.getWindow()!!.setAttributes(var1)
            } catch (var2: Throwable) {
            }
        }
    }

    interface OnDramaRewardDialogListener {
        fun onConfirm()

        fun onCancel()
    }
}