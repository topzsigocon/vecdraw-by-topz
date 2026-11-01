package com.topz.vecdraw

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.view.MotionEvent
import android.view.View
import kotlin.math.min

class DrawingCanvasView(context: Context) : View(context) {
    data class Item(val tool: String, val rect: RectF, val path: Path? = null)

    private val items = mutableListOf<Item>()
    private val undoStack = mutableListOf<List<Item>>()
    private val gridPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(43, 59, 78); strokeWidth = 1f
    }
    private val shapePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(229, 169, 60); style = Paint.Style.STROKE; strokeWidth = 4f
    }
    private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(35, 229, 169, 60); style = Paint.Style.FILL
    }
    private val previewPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE; style = Paint.Style.STROKE; strokeWidth = 2f
    }
    var currentTool: String = "Pick"
    private var startX = 0f
    private var startY = 0f
    private var activePath: Path? = null
    private var drawing = false

    init { setLayerType(View.LAYER_TYPE_SOFTWARE, null) }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        canvas.drawColor(Color.rgb(22, 31, 43))
        val step = 40f * resources.displayMetrics.density
        var x = 0f
        while (x < width) { canvas.drawLine(x, 0f, x, height.toFloat(), gridPaint); x += step }
        var y = 0f
        while (y < height) { canvas.drawLine(0f, y, width.toFloat(), y, gridPaint); y += step }

        items.forEach { item ->
            when (item.tool) {
                "Rect" -> { canvas.drawRect(item.rect, fillPaint); canvas.drawRect(item.rect, shapePaint) }
                "Ellipse" -> { canvas.drawOval(item.rect, fillPaint); canvas.drawOval(item.rect, shapePaint) }
                "Pen" -> item.path?.let { canvas.drawPath(it, shapePaint) }
            }
        }
        if (drawing) {
            val rect = normalized(startX, startY, lastX, lastY)
            when (currentTool) {
                "Rect" -> canvas.drawRect(rect, previewPaint)
                "Ellipse" -> canvas.drawOval(rect, previewPaint)
                "Pen" -> activePath?.let { canvas.drawPath(it, previewPaint) }
            }
        }
    }

    private var lastX = 0f
    private var lastY = 0f

    override fun onTouchEvent(event: MotionEvent): Boolean {
        val x = event.x
        val y = event.y
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                startX = x; startY = y; lastX = x; lastY = y
                drawing = currentTool != "Pick"
                if (currentTool == "Pen") activePath = Path().apply { moveTo(x, y) }
                invalidate()
                return true
            }
            MotionEvent.ACTION_MOVE -> {
                lastX = x; lastY = y
                if (currentTool == "Pen") activePath?.lineTo(x, y)
                invalidate()
                return true
            }
            MotionEvent.ACTION_UP -> {
                lastX = x; lastY = y
                if (drawing) {
                    undoStack.add(items.toList())
                    val rect = normalized(startX, startY, x, y)
                    when (currentTool) {
                        "Rect", "Ellipse" -> if (rect.width() > 2 && rect.height() > 2) items.add(Item(currentTool, rect))
                        "Pen" -> activePath?.let { items.add(Item("Pen", RectF(), Path(it))) }
                    }
                }
                drawing = false; activePath = null; invalidate()
                return true
            }
        }
        return true
    }

    private fun normalized(x1: Float, y1: Float, x2: Float, y2: Float) =
        RectF(min(x1, x2), min(y1, y2), maxOf(x1, x2), maxOf(y1, y2))

    fun undo() {
        if (undoStack.isNotEmpty()) {
            items.clear(); items.addAll(undoStack.removeAt(undoStack.lastIndex)); invalidate()
        }
    }
    fun clear() {
        if (items.isNotEmpty()) undoStack.add(items.toList())
        items.clear(); invalidate()
    }
}
