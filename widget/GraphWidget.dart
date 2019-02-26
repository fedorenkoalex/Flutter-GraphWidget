import 'dart:ui' as UI;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/animation.dart';
import 'BlocProvider.dart';
import 'GraphWidgetBloc.dart';

enum ScrollDirection { LEFT, RIGHT }

///Constants class
class GraphConst {
  ///Wrap widget width (or height) to screen width (or height).
  static const double WRAP = -1.0;

  /// Set auto max Y scale.
  static const int AUTO = -1;
}

class GraphPoint {
  ///GraphPoint X coordinate.
  double x;

  ///GraphPoint Y coordinate.
  double y;

  GraphPoint({@required this.x, @required this.y});
}

class GraphParams {
  ///Points of Graph. Array of [GraphPoint(x: value, y: value)]
  final List<GraphPoint> graphPoints;

  /// Left (X) widget offset.
  /// Default is 0.0.
  final double left;

  /// Top (Y) widget offset.
  /// Default is 0.0.
  final double top;

  /// Additional free area for scrolling before Graph.
  /// Default is 0.0.
  final double startOverScroll;

  /// Additional free area for scrolling after Graph.
  /// Default is 0.0.
  final double endOverScroll;

  /// Count of grid lines at Y coordinate.
  /// Default is 10.
  final int yGridSize;

  ///Duration of scroll animation
  ///in milliseconds
  final int scrollDuration;

  ///
  /// Points radius [double]
  final double pointRadius;

  ///Max point at screen at X coordinate
  ///Using only when scrolling is enabled;
  ///To use Y scale size depending on Graph max value - use [GraphConst.AUTO].
  int yScale;

  ///Max point of Y coordinate;
  int xScale;

  ///Show markings every X value
  ///For example:
  ///[showMarkingsEveryX] = 5; ,markings = 5,10,15 etc
  ///to enable all markings set [showMarkingsEveryX] to 0.
  int showMarkingsEveryX;

  /// Enable or disable rounding Graph corners.
  /// Disabled by default.
  bool enableRoundCorners;

  /// Enable or disable fill Graph with paint or Gradient.
  /// Disabled by default.
  bool enableFill;

  /// Enable or disable text markings at the bottom of Graph.
  /// Disabled by default.
  bool enableMarks;

  /// Enable or disable grid.
  /// Disabled by default.
  bool enableGrid;

  /// Enable or disable scrolling.
  /// Disabled by default.
  bool enableScroll;

  /// Enable or disable scroll fling.
  /// Disabled by default.
  bool enableFling;

  /// Enable or disable points .
  /// Disabled by default.
  bool enablePoints;

  /// Widget height.
  /// To use screen height use [GraphConst.WRAP].
  double height;

  /// Widget width.
  /// To use screen width use [GraphConst.WRAP].
  double width;

  /// [Paint] of Graph.
  Paint mainLinePaint;

  /// [Gradient] of Graph paint .
  Gradient gradient;

  /// [Paint] of Grid .
  Paint gridPaint;

  /// [Paint] of Point at Graph .
  Paint pointsPaint;

  /// [Paint] of background .
  Paint bgdPaint;

  /// [Paint] of Markings background .
  Paint marksBgdPaint;

  /// Markings text style [UI.TextStyle].
  UI.TextStyle textStyle;

  double offset;

  GraphParams(
      {@required this.graphPoints,
      this.offset = 0.0,
      this.width = GraphConst.WRAP,
      this.height = GraphConst.WRAP,
      this.startOverScroll = 0.0,
      this.endOverScroll = 0.0,
      this.left = 0.0,
      this.top = 0.0,
      this.yGridSize = 10,
      this.scrollDuration = 1000,
      this.pointRadius = 2.0,
      this.showMarkingsEveryX = 0,
      this.enableFill = false,
      this.enableRoundCorners = false,
      this.enableMarks = false,
      this.enableGrid = false,
      this.enableScroll = false,
      this.enableFling = false,
      this.enablePoints = false,
      this.mainLinePaint,
      this.gradient,
      this.gridPaint,
      this.pointsPaint,
      this.bgdPaint,
      this.marksBgdPaint,
      this.textStyle,
      this.yScale = GraphConst.AUTO,
      this.xScale = 5});

  bool isSizeValid() {
    return height != GraphConst.WRAP && width != GraphConst.WRAP;
  }
}

class _SortedGraphPoint {
  final int globalPosition;
  final double x;
  final double y;
  final bool isOnScreen;

  _SortedGraphPoint(
      {@required this.globalPosition,
      @required this.x,
      @required this.y,
      this.isOnScreen});
}

class GraphWidget extends StatelessWidget {
  static const double ZERO = 0.0;

  ///
  /// [GraphParams] object
  /// settings for GraphWidget
  final GraphParams params;

  ///
  /// [GlobalKey<GraphWidgetState>] need for moving or scrolling Graph.
  /// Setup like [GlobalKey<GraphWidgetState> widgetKey = GlobalKey();]
  final GlobalKey<GraphWidgetInternalState> widgetKey;

  GraphWidget({this.widgetKey, @required this.params});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        child: _GraphWidgetInternal(widgetKey: widgetKey),
        bloc: GraphWidgetBloc(context: context, params: params));
  }
}

class _GraphWidgetInternal extends StatefulWidget {
  final GlobalKey<GraphWidgetInternalState> widgetKey;

  _GraphWidgetInternal({@required this.widgetKey}) : super(key: widgetKey);

  GraphWidgetInternalState createState() => GraphWidgetInternalState();
}

class GraphWidgetInternalState extends State<_GraphWidgetInternal>
    with TickerProviderStateMixin {
  final double _flingEndMultiplier = 200.0;
  final double _flingDurationMultiplier = 10;

  GraphWidgetBloc _bloc;
  AnimationController _controllerRight;
  AnimationController _controllerLeft;
  AnimationController _controllerMove;
  Animation<double> _animationRight;
  Animation<double> _animationLeft;
  Animation<double> _animationMove;

  moveTo(int pointPosition) {
    _bloc.moveTo(pointPosition);
  }

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<GraphWidgetBloc>(context);
  }

  @override
  void dispose() {
    _controllerLeft?.dispose();
    _controllerRight?.dispose();
    _controllerMove?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (!_bloc.isFlingEnabled()) {
          return;
        }
        if (_getScrollDirection(details.velocity.pixelsPerSecond.dx) ==
            ScrollDirection.RIGHT) {
          _initAnimationsForRight(details);
          _controllerRight.forward(from: 0);
        } else if (_getScrollDirection(details.velocity.pixelsPerSecond.dx) ==
            ScrollDirection.LEFT) {
          _initAnimationsForLeft(details);
          _controllerLeft.forward(from: 0);
        }
      },
      onHorizontalDragUpdate: (details) {
        if (_bloc.isScrollBlockedLeft()) {
          if (_getScrollDirection(details.delta.dx) == ScrollDirection.LEFT) {
            return;
          }
        }
        if (_bloc.isScrollBlockedRight()) {
          if (_getScrollDirection(details.delta.dx) == ScrollDirection.RIGHT) {
            return;
          }
        }
        _bloc.increaseOffset(details.delta.dx);
      },
      child: StreamBuilder(
          stream: _bloc.paramsStream,
          initialData: GraphParams(graphPoints: List()),
          builder: (BuildContext context, AsyncSnapshot<GraphParams> snapshot) {
            if (!snapshot.data.isSizeValid()) {
              return Container();
            }
            return SizedBox(
                height: snapshot.data.height,
                width: snapshot.data.width,
                child: CustomPaint(
                  painter:
                      _GraphWidgetPainter(params: snapshot.data, bloc: _bloc),
                ));
          }),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc ?? _bloc.initSizes();
  }

  _initAnimationsForRight(DragEndDetails details) {
    double endValue =
        -details.velocity.pixelsPerSecond.distance / _flingEndMultiplier;

    endValue = _bloc.calculateRightEndValue(endValue);

    int animDuration = _getFlingDuration(details.primaryVelocity);

    _controllerRight = AnimationController(
        duration: Duration(milliseconds: animDuration), vsync: this);
    _animationRight = Tween<double>(begin: 0, end: endValue).animate(
        CurvedAnimation(
            parent: _controllerRight, curve: Curves.fastLinearToSlowEaseIn))
      ..addListener(() {
        if (_bloc.isScrollBlockedRight()) {
          return;
        }
        _bloc.increaseOffset(_animationRight.value);
      });
    _controllerRight.fling(velocity: details.primaryVelocity);
  }

  _initAnimationsForLeft(DragEndDetails details) {
    double endValue =
        details.velocity.pixelsPerSecond.distance / _flingEndMultiplier;

    endValue = _bloc.calculateLeftEndValue(endValue);

    int animDuration = _getFlingDuration(details.primaryVelocity);
    _controllerLeft = AnimationController(
        duration: Duration(milliseconds: animDuration), vsync: this);
    _animationLeft = Tween<double>(begin: 0, end: endValue).animate(
        CurvedAnimation(
            parent: _controllerLeft, curve: Curves.fastLinearToSlowEaseIn))
      ..addListener(() {
        if (_bloc.isScrollBlockedLeft()) {
          return;
        }
        _bloc.increaseOffset(_animationLeft.value);
      });
    _controllerLeft.fling(velocity: details.primaryVelocity);
  }

  int _getFlingDuration(double velocity) {
    return (velocity ~/ _flingDurationMultiplier).abs();
  }

  void scrollTo(int pointPosition) {
    double endValue = _bloc.getXForPosition(pointPosition);
    _controllerMove = AnimationController(
        duration: Duration(milliseconds: _bloc.getScrollDuration()),
        vsync: this);
    _animationMove =
        Tween<double>(begin: _bloc.getOffset().abs(), end: endValue.abs())
            .animate(_controllerMove)
              ..addListener(() {
                _bloc.setOffset(-_animationMove.value);
              });
    _controllerMove.forward();
  }

  ScrollDirection _getScrollDirection(double dx) {
    return (dx > 0) ? ScrollDirection.LEFT : ScrollDirection.RIGHT;
  }
}

const double ZERO = 0.0;
const double ADDITIONAL_LINE_OFFSET = 10.0;

class _GraphWidgetPainter extends CustomPainter {
  final GraphParams params;
  final GraphWidgetBloc bloc;

  _GraphWidgetPainter({@required this.params, @required this.bloc}) {
    params.mainLinePaint ??= _initDefMainLinePaint();
    params.gridPaint ??= _initDefGridLinePaint();
    params.pointsPaint ??= _initDefPointPaint();
    params.bgdPaint ??= _initDefBgdPaint();
    params.marksBgdPaint ??= _initDefMarkingBgdPaint();
    params.textStyle ??= _initDefMarkingsTextStyle();
  }

  Paint _initDefMainLinePaint() {
    return Paint()
      ..style = params.enableFill ? PaintingStyle.fill : PaintingStyle.stroke
      ..color = Colors.red
      ..isAntiAlias = true
      ..shader = (params.gradient != null)
          ? params.gradient.createShader(Rect.fromLTRB(
              params.left, params.top, params.width, bloc.getHeightForGraph()))
          : null;
  }

  Paint _initDefGridLinePaint() {
    return Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blueAccent
      ..isAntiAlias = true;
  }

  Paint _initDefPointPaint() {
    return Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green
      ..isAntiAlias = true;
  }

  Paint _initDefBgdPaint() {
    return Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white
      ..isAntiAlias = true;
  }

  Paint _initDefMarkingBgdPaint() {
    return Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey
      ..isAntiAlias = true;
  }

  UI.TextStyle _initDefMarkingsTextStyle() {
    if (params.width == ZERO) {
      return null;
    }
    return UI.TextStyle(fontSize: bloc.getTextSize(), color: Colors.white);
  }

  _checkMainStyle() {
    params.mainLinePaint.style =
        params.enableFill ? PaintingStyle.fill : PaintingStyle.stroke;
    params.mainLinePaint.shader = (params.gradient != null)
        ? params.gradient.createShader(Rect.fromLTRB(
            params.left, params.top, params.width, bloc.getHeightForGraph()))
        : null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (params.xScale >= params.graphPoints.length) {
      params.enableScroll = false;
    }

    _checkMainStyle();

    canvas.drawRect(
        Rect.fromLTRB(params.left, params.top, params.width, params.height),
        params.bgdPaint);

    if (params.offset > bloc.getGraphLeftEnd()) {
      params.offset = bloc.getGraphLeftEnd();
    }
    if (params.offset < bloc.getGraphRightEnd()) {
      params.offset = bloc.getGraphRightEnd();
    }

    List<_SortedGraphPoint> pointsOnScreen = getPointsOnScreen();
    if (pointsOnScreen.length == 0) {
      return;
    }
    Path drawingPath = Path();
    drawingPath.moveTo(pointsOnScreen[0].x, bloc.getHeightForGraph());

    if (params.enableGrid) {
      for (int i = 0; i < pointsOnScreen.length; i++) {
        canvas.drawLine(
            Offset(pointsOnScreen[i].x, params.top),
            Offset(pointsOnScreen[i].x, bloc.getHeightForGraphWithTop()),
            params.gridPaint);
      }

      for (int i = 0; i < params.yGridSize; i++) {
        canvas.drawLine(
            Offset(params.left, params.top + bloc.getGridYParam() * i),
            Offset(
                bloc.getWidthWithLeft(), params.top + bloc.getGridYParam() * i),
            params.gridPaint);
      }
    }

    if (params.enableMarks) {
      Rect unterTitleRect = Rect.fromLTRB(params.left, bloc.getUnderTitleTop(),
          bloc.getWidthWithLeft(), bloc.getHeightWithTop());
      canvas.drawRect(unterTitleRect, params.marksBgdPaint);
    }

    for (int i = 0; i < pointsOnScreen.length; i++) {
      var pointCenter = Offset(pointsOnScreen[i].x, pointsOnScreen[i].y);
      if (params.enablePoints) {
        canvas.drawCircle(pointCenter, params.pointRadius, params.pointsPaint);
      }
      if (params.enableMarks && pointsOnScreen[i].isOnScreen) {
        if (params.showMarkingsEveryX == 0 ||
            i % params.showMarkingsEveryX == 0) {
          UI.ParagraphBuilder builder = UI.ParagraphBuilder(
              UI.ParagraphStyle(textDirection: UI.TextDirection.ltr))
            ..pushStyle(params.textStyle)
            ..addText(pointsOnScreen[i].globalPosition.toString());

          UI.Paragraph paragraph = builder.build()
            ..layout(UI.ParagraphConstraints(width: bloc.getTextWidth()));

          double textY =
              (((bloc.getHeightWithTop()) - bloc.getUnderTitleTop()) -
                      paragraph.height) /
                  2;

          canvas.drawParagraph(paragraph,
              Offset(pointsOnScreen[i].x, bloc.getUnderTitleTop() + textY));
        }
      }

      double prevPointX = 0.0;
      double prevPointY = 0.0;
      if (i <= 0) {
        prevPointX = pointsOnScreen[0].x;
        prevPointY = bloc.getHeightForGraphWithTop();
      } else {
        prevPointX = pointsOnScreen[i - 1].x;
        prevPointY = pointsOnScreen[i - 1].y;
      }

      if (params.enableRoundCorners) {
        drawingPath.cubicTo(
            (prevPointX + pointsOnScreen[i].x) / 2,
            prevPointY,
            (prevPointX + pointsOnScreen[i].x) / 2,
            pointsOnScreen[i].y,
            pointsOnScreen[i].x,
            pointsOnScreen[i].y);
      } else {
        drawingPath.lineTo(pointsOnScreen[i].x, pointsOnScreen[i].y);
      }
      if (i == pointsOnScreen.length - 1) {
        drawingPath.lineTo(
            pointsOnScreen[i].x, bloc.getHeightForGraphWithTop());
        drawingPath.lineTo(
            pointsOnScreen[0].x, bloc.getHeightForGraphWithTop());
        drawingPath.close();
      }
    }

    canvas.drawPath(drawingPath, params.mainLinePaint);

    if (!pointsOnScreen.first.isOnScreen) {
      Rect leftHolder = Rect.fromLTRB(pointsOnScreen.first.x - 10.0, params.top,
          params.left, bloc.getHeightForGraphWithTop());
      canvas.drawRect(leftHolder, params.bgdPaint);
    }
    if (!pointsOnScreen.last.isOnScreen) {
      Rect leftHolder = Rect.fromLTRB(bloc.getWidthWithLeft(), params.top,
          pointsOnScreen.last.x + 10.0, bloc.getHeightForGraphWithTop());
      canvas.drawRect(leftHolder, params.bgdPaint);
    }

    canvas.save();
    canvas.restore();
  }

  List<_SortedGraphPoint> getPointsOnScreen() {
    if (params.graphPoints == null) {
      return List();
    }
    List<_SortedGraphPoint> tmpPointsOnScreen = List<_SortedGraphPoint>();
    if (!params.enableScroll) {
      for (int i = 0; i < params.graphPoints.length; i++) {
        double pointX = bloc.getPointX(params.graphPoints[i].x);
        tmpPointsOnScreen.add(_SortedGraphPoint(
            globalPosition: i,
            x: pointX,
            y: bloc.getAxisYFromBottom(params.graphPoints[i].y),
            isOnScreen: true));
      }
      return tmpPointsOnScreen;
    }

    for (int i = 0; i < params.graphPoints.length; i++) {
      double pointX = bloc.getPointX(params.graphPoints[i].x);
      if (bloc.isPointOnScreen(pointX)) {
        tmpPointsOnScreen.add(_SortedGraphPoint(
            globalPosition: i,
            x: pointX,
            y: bloc.getAxisYFromBottom(params.graphPoints[i].y),
            isOnScreen: true));
      }
    }
    if (tmpPointsOnScreen.length == 0) {
      return List();
    }

    List<_SortedGraphPoint> pointsOnScreen = List<_SortedGraphPoint>();
    if (tmpPointsOnScreen[0].globalPosition > 0) {
      int globalPosition = tmpPointsOnScreen[0].globalPosition - 1;
      pointsOnScreen.add(_SortedGraphPoint(
          globalPosition: globalPosition,
          x: bloc.getPointX(params.graphPoints[globalPosition].x),
          y: bloc.getAxisYFromBottom(params.graphPoints[globalPosition].y),
          isOnScreen: false));
    }
    pointsOnScreen.addAll(tmpPointsOnScreen);

    if (tmpPointsOnScreen[tmpPointsOnScreen.length - 1].globalPosition <
        params.graphPoints.length - 1) {
      int globalPosition =
          tmpPointsOnScreen[tmpPointsOnScreen.length - 1].globalPosition + 1;
      pointsOnScreen.add(_SortedGraphPoint(
          globalPosition: globalPosition,
          x: bloc.getPointX(params.graphPoints[globalPosition].x),
          y: bloc.getAxisYFromBottom(params.graphPoints[globalPosition].y),
          isOnScreen: false));
    }

    return pointsOnScreen;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
