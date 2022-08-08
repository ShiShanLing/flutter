import 'dart:math';

import 'package:copd_audio_analysis/COPDHead/COPDHead.dart';
import 'package:flutter/material.dart';

// COPDRecord
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;

typedef VoidCallback = void Function();

class RecordButton extends StatefulWidget {

  RecordButton({Key? key,required this.size, required this.seconds, required this.onStart, required this.onEnd, this.enabled = true}) : super(key: key);
  Size size;
  int seconds;
  void Function() onStart;
  void Function() onEnd;
  bool enabled = true;
  @override
  State<RecordButton> createState() => _RecordButtonState();
}


class _RecordButtonState extends State<RecordButton> with TickerProviderStateMixin {
  late AnimationController _animationController2;
  late AnimationController _animationController3;
  int countdownSeconds = 60;
  @override
  void initState() {
// TODO: implement initState
    super.initState();

    _animationController2 =
    AnimationController(duration: Duration(milliseconds: 100), vsync: this)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          //按钮过渡动画完成后启动录制视频的进度条动画
          _animationController3.forward();
          widget.onStart();
        }
      });
    //第二个控制器
    _animationController3 =
    AnimationController(duration: Duration(seconds: widget.seconds), vsync: this)
      ..addListener(() {
        setState(() {});
        print("_animationController3.value -- ${_animationController3.value}");
        if (_animationController3.value == 1){
          _animationController2.reverse();
          _animationController3.value = 0;
          _animationController3.stop();
          widget.onEnd();
        }
      });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0),
      width: widget.size.width,
      height: widget.size.height,
      color: Colors.transparent,
      alignment: Alignment.center,
      child: _getButton(),
    );
  }

  Widget _getButton(){
    return GestureDetector(
      onLongPress: () {
        if (widget.enabled){
          countdownSeconds = widget.seconds;
          _animationController2.forward();
        }
      },
      onLongPressUp: () {
        _animationController2.reverse();
        _animationController3.value = 0;
        _animationController3.stop();
        widget.onEnd();
      },
      child: Stack(
        children: [
          Align(
            child: _getCustomPaint(),
            alignment: const FractionalOffset(0.5, 0.5),
          )
        ],
      ),
    );
  }

  Widget _getCustomPaint(){
    return CustomPaint(
      painter: RecordCustomPaint(
          _animationController2.value, _animationController3.value, widget.size),
      size: widget.size,
    );
  }

}

class RecordCustomPaint extends CustomPainter {
  final double firstProgress; //第一段动画控制值，值范围[0,1]

  final double secondProgress; //第二段动画控制值，值范围[0,1]

  //主按钮的颜色
  final Color buttonColor = Colors.red;

  final Color mainColor = kColor(223,104,104, 1);
  //进度条相关参数
  final double progressWidth = kFit(10); //进度条 宽度
  final Color progressColor = Colors.white; //kColor(223,104,104, 1); //进度条颜色
  final double back90 = deg2Rad(-90.0).toDouble(); //往前推90度 从12点钟方向开始
  //主按钮背后一层的颜色，也是progress绘制时的背景色
  late Color progressBackgroundColor;

  //主按钮画笔
  late Paint mainBtnPaint;
  //画笔颜色
  Color mainBtnColor = Colors.white;
  //主按钮进度条画笔
  late Paint mainBtnProgressPaint;
  //渐变色
  List<Color> mainBtnGradientColors = [Colors.red, Colors.yellow];
  //主按钮和外圈之间的阴影画笔
  late Paint spacerShadowPaint;
  //主按钮和外圈之间的阴影渐变色
  List<Color> spacerShadowColors = [kColor(233, 229, 214, 1), kColor(249,  239, 225, 1)];
  //外圈画笔
  late Paint outerRingPaint;
  //外圈画笔颜色
  Color outerRingColor = Colors.white;
  //进度条画笔
  late Paint progressPaint;
  //进度条画笔渐变色
  List<Color> progressGradientColors = [Colors.red, Colors.yellow];

  RecordCustomPaint(this.firstProgress, this.secondProgress,Size tsize) {
      progressBackgroundColor = kColor(225, 234, 238, 1);
// 按钮圆，按钮圆初始半径刚开始时应减去 进度条的宽度，在长按时按钮圆半径变小
    final double initBtnCircleRadius = tsize.width * 0.5 - kFit(67);


    mainBtnPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = mainBtnColor
      ..strokeWidth = initBtnCircleRadius;

    final double center = tsize.width * 0.5;
    mainBtnProgressPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = ui.Gradient.sweep(Offset(center, center), [Colors.red, Colors.yellow], null, TileMode.clamp ,deg2Rad(-90.0).toDouble(), math.pi * 2, null)
        ..strokeWidth = initBtnCircleRadius;

    final double outerRingRadius = initBtnCircleRadius +kFit(7.5);

    spacerShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..shader = ui.Gradient.radial(Offset(center, center),outerRingRadius, spacerShadowColors, null, TileMode.mirror ,null, null, 0)
      ..strokeWidth = kFit(15);

      //按钮外圈
      outerRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = outerRingColor
        ..strokeWidth = kFit(6);
      //进度条
      progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..shader = ui.Gradient.sweep(Offset(center, center), [Colors.red, Colors.yellow], null, TileMode.clamp ,deg2Rad(0).toDouble(), math.pi * 2, null)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = progressWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    outerRingPaint.strokeWidth = kFit(6) + kFit(10) * firstProgress;
    double color_opacity = secondProgress + 0.2;
    if (color_opacity > 1){
      color_opacity = 1;
    }
    // 底部最大的圆
    final double center = size.width * 0.5;
    //圆心
    final Offset circleCenter = Offset(center, center);
    // 按钮圆，按钮圆初始半径刚开始时应减去 进度条的宽度，在长按时按钮圆半径变小
    final double initBtnCircleRadius = size.width * 0.5 - kFit(72);

    canvas.translate(0.0, size.width);
    canvas.rotate(back90);

    //15是内外圈的间隔,6是变粗之前的线宽 kFit(5) * firstProgress 是变粗的宽度
    final double outerRingRadius = initBtnCircleRadius + kFit(15) + kFit(6) + kFit(5) * firstProgress;
    //角度转化为弧度
    final double outerRingSweepAngle = deg2Rad(360.0).toDouble();
    //画 主按钮
    _drawMainBtn(){
      //角度转化为弧度
      final double sweepAngle = deg2Rad(360.0).toDouble();
      final Rect btnArcRect =
      Rect.fromCircle(center: circleCenter, radius: initBtnCircleRadius);
      canvas.drawArc(btnArcRect, 0, sweepAngle, true, mainBtnPaint);
    }
    //主按钮渐变
    _drawMainBtnProgress(){
      //内圈圆渐变色
      if (secondProgress > 0) {
        // print("比例是: ${toW/currentW}");
        //secondProgress 值转化为度数
        final double angle = 360.0 * secondProgress;
        //角度转化为弧度
        final double sweepAngle = deg2Rad(angle).toDouble();
        final Rect btnArcRect =
        Rect.fromCircle(center: circleCenter, radius: initBtnCircleRadius);
        canvas.drawArc(btnArcRect, 0, sweepAngle, true, mainBtnProgressPaint);
      }
    }
    //主按钮和外圈之间的阴影
    _drwaSpacerShadow(){
      final Rect arcRect =
      Rect.fromCircle(center: circleCenter, radius:initBtnCircleRadius + kFit(7.5));
      //这里画弧度的时候它默认起点是从3点钟方向开始
      // 所以这里的开始角度向前调整90度让它从12点钟方向开始画弧
      canvas.drawArc(arcRect, back90, outerRingSweepAngle, false, spacerShadowPaint);
    }
    //外圈
    _drawOuterRing(){
      final Rect arcRect =
      Rect.fromCircle(center: circleCenter, radius: outerRingRadius);
      //这里画弧度的时候它默认起点是从3点钟方向开始
      // 所以这里的开始角度向前调整90度让它从12点钟方向开始画弧
      canvas.drawArc(arcRect, back90, outerRingSweepAngle, false, outerRingPaint);
    }
    //绘制外圈进度条
    _drawOuterRingProgress(){
      if (secondProgress > 0) {

        var offset = asin(progressWidth * 0.5 / outerRingRadius);

        final double angle = 360.0 * secondProgress;
        final double progressCircleRadius = outerRingRadius;
        final double sweepAngle = deg2Rad(angle).toDouble();
        final Rect arcRect =
        Rect.fromCircle(center: circleCenter, radius: progressCircleRadius);
        canvas.drawArc(arcRect, offset, sweepAngle, false, progressPaint);
      }
    }


    //绘制主按钮
    _drawMainBtn();
    //绘制主按钮渐变色
    _drawMainBtnProgress();
    //阴影绘制
    _drwaSpacerShadow();
    //绘制外圈
    _drawOuterRing();
    //绘制外圈进度条
    _drawOuterRingProgress();

  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

//角度转弧度
num deg2Rad(num deg) => deg * (math.pi / 180.0);