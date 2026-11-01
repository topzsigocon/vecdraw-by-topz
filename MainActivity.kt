package com.topz.vecdraw

import android.app.Activity
import android.os.Bundle
import android.graphics.Color
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class MainActivity : Activity() {
    private lateinit var canvasView: DrawingCanvasView
    private lateinit var status: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.statusBarColor = Color.rgb(7, 17, 31)
        window.navigationBarColor = Color.rgb(7, 17, 31)
        window.decorView.systemUiVisibility = 0

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.rgb(11, 25, 44))
        }

        val header = TextView(this).apply {
            text = "  VecDraw by Topz     •     VECTOR EDITOR"
            setTextColor(Color.rgb(229, 169, 60))
            textSize = 16f
            gravity = Gravity.CENTER_VERTICAL
            setPadding(12, 0, 12, 0)
            setBackgroundColor(Color.rgb(7, 17, 31))
        }
        root.addView(header, LinearLayout.LayoutParams(-1, dp(52)))

        val tools = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setBackgroundColor(Color.rgb(17, 35, 57))
        }
        val toolNames = listOf("Pick", "Pen", "Rect", "Ellipse", "Undo", "Clear")
        toolNames.forEach { name ->
            val b = Button(this).apply {
                text = name
                textSize = 11f
                isAllCaps = false
                setOnClickListener {
                    when (name) {
                        "Undo" -> canvasView.undo()
                        "Clear" -> canvasView.clear()
                        else -> {
                            canvasView.currentTool = name
                            status.text = "Tool: $name"
                        }
                    }
                }
            }
            tools.addView(b, LinearLayout.LayoutParams(0, dp(48), 1f))
        }
        root.addView(tools)

        canvasView = DrawingCanvasView(this)
        root.addView(canvasView, LinearLayout.LayoutParams(-1, 0, 1f))

        status = TextView(this).apply {
            text = "Ready  •  Select a tool and draw on the canvas"
            textSize = 12f
            setTextColor(Color.LTGRAY)
            gravity = Gravity.CENTER_VERTICAL
            setPadding(12, 0, 12, 0)
            setBackgroundColor(Color.rgb(7, 17, 31))
        }
        root.addView(status, LinearLayout.LayoutParams(-1, dp(36)))
        setContentView(root)
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()
}
