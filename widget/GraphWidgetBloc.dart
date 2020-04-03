import 'BlocBase.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'GraphWidget.dart';

class GraphWidgetBloc implements BlocBase {
  StreamController<GraphParams> _paramsProvideController =
      StreamController<GraphParams>();

  StreamSink<GraphParams> get _paramsSink => _paramsProvideController.sink;

  Stream<GraphParams> get paramsStream => _paramsProvideController.stream;

  final GraphParams params;
  final BuildContext context;

  GraphWidgetBloc({this.context, this.params});

  void init() {
    initSizes();
    if (params.yScale == GraphConst.AUTO) {
      params.yScale = _findMaxValue();
    }
    _paramsSink.add(params);
  }

  @override
  void dispose() {
    _paramsProvideController.close();
  }

  moveTo(int pointPosition) {
    double pointPositionX = getXForPosition(pointPosition);
    setOffset(-pointPositionX);
  }

  double getScrollUpperBound(double endValue) {
    return getPointXForMove(
        params.graphPoints[params.graphPoints.length - 1].x);
  }

  int getScrollDuration() {
    return params.scrollDuration;
  }

  double getOffset() {
    return params.offset;
  }

  double getPointX(double i) {
    return (params.enableScroll)
        ? (((params.width / params.xScale) * i) + params.offset + params.left)
        : (((params.width /
                    (params.graphPoints[params.graphPoints.length - 1].x)) *
                i) +
            params.left);
  }

  double getXForPosition(int pointPosition) {
    int clearPoint = (pointPosition - params.xScale / 2).toInt();
    return getPointXForMove(
        params.graphPoints[(clearPoint < 0) ? pointPosition : clearPoint].x);
  }

  double getPointXForMove(double i) {
    return ((params.width / params.xScale) * i) + params.left;
  }

  double getGridYParam() {
    return getHeightForGraph() / params.yGridSize;
  }

  double getHeightForGraph() {
    return params.enableMarks
        ? params.height - (params.height * 10.0 / 100.0)
        : params.height;
  }

  double getHeightForGraphWithTop() {
    return getHeightForGraph() + params.top;
  }

  double getWidthWithLeft() {
    return params.left + params.width;
  }

  double getHeightWithTop() {
    return params.top + params.height;
  }

  double getUnderTitleTop() {
    return params.height - (params.height * 10.0 / 100.0) + params.top;
  }

  double getTextSize() {
    return params.width * 4.0 / 100.0;
  }

  double getTextWidth() {
    return params.width * 7.0 / 100.0;
  }

  bool isPointOnScreen(double point) {
    return point > params.left && point < params.left + params.width;
  }

  double getAxisY(double param) {
    return (param * getHeightForGraph()) / params.yScale + params.top;
  }

  double getAxisYFromBottom(double param) {
    return getHeightForGraph() -
        ((param * (getHeightForGraph() / params.yScale))) +
        params.top;
  }

  increaseOffset(double delta) {
    params.offset = params.offset + delta;
    _paramsSink.add(params);
  }

  setOffset(double offset) {
    params.offset = offset;
    _paramsSink.add(params);
  }

  double calculateRightEndValue(double endValue) {
    if (endValue < params.offset + getGraphRightEnd()) {
      return params.offset + getGraphRightEnd();
    }
    return endValue;
  }

  double calculateLeftEndValue(double endValue) {
    if (endValue < params.offset + getGraphLeftEnd()) {
      return params.offset + getGraphLeftEnd();
    }
    return endValue;
  }

  bool isFlingEnabled() {
    return params.enableFling;
  }

  bool isScrollBlockedLeft() {
    return params.offset == getGraphLeftEnd();
  }

  double getGraphLeftEnd() {
    return params.left + params.startOverScroll;
  }

  bool isScrollBlockedRight() {
    return params.offset == getGraphRightEnd();
  }

  double getGraphRightEnd() {
    return ((params.graphPoints[params.graphPoints.length - 1].x) *
            -(params.width / params.xScale)) +
        params.width +
        params.left -
        params.endOverScroll;
  }

  initSizes() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (params.width == GraphConst.WRAP || params.width == GraphWidget.ZERO) {
      params.width = screenWidth - params.left;
    }
    if (params.height == GraphConst.WRAP || params.height == GraphWidget.ZERO) {
      params.height = screenHeight - params.top;
    }
  }

  int _findMaxValue() {
    int maxValue = params.graphPoints[0].y.toInt();
    for (int i = 0; i < params.graphPoints.length; i++) {
      if (params.graphPoints[i].y > maxValue) {
        maxValue = params.graphPoints[i].y.toInt();
      }
    }
    return maxValue;
  }
}
