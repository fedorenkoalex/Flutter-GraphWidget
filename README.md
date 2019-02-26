
# Flutter GraphWidget


<img src="https://github.com/fedorenkoalex/Flutter-GraphWidget/blob/master/raw/imgs/pic1.jpg" width="250">
<img src="https://github.com/fedorenkoalex/Flutter-GraphWidget/blob/master/raw/imgs/pic2.jpg" width="250">

#### 1. Installing
 - copy [Widget](widget/) folder to Your project.
 - use =)
 - demo app avaliable [HERE](raw/app-release.apk)
#### 2. Usage
 - Setup variables and GraphParams. Here you can setup your Graph.(For details look at 3. Graph Params) 
For example:
 - Create a GlobalKey:
```GlobalKey<GraphWidgetInternalState> widgetKey = GlobalKey();```
 - Create a List:
```
List<GraphPoint> values = List();
for (int i = 0; i < 100; i++) {
      var rng = new Random();
      values.add(GraphPoint(x: i.toDouble(), y: rng.nextInt(500).toDouble()));
    }
```
 - Setup GraphParams:
```
GraphParams params = GraphParams(
        graphPoints: values,
        height: 200.0,
        width: GraphConst.WRAP,
        top: 16.0,
       yGridSize: 10,
        yScale: GraphConst.AUTO,
        xScale: 10,
        startOverScroll: 0.0,
        endOverScroll: 0.0,
        enableRoundCorners: false,
        enableFill: false,
        enableMarks: false,
        enableGrid: false,
        enableScroll: true,
        textStyle: getTextStyle(),
        marksBgdPaint: _getMarksBgd(),
        gradient: _getGradient());
```
 - Next Setup a Widget
For example:
```
    GraphWidget(widgetKey: widgetKey, params: params)
```
 - For scroll or move Graph you can use functions:
 ```
 widgetKey.currentState.moveTo(int position);
 ```
 or 
 ```
 widgetKey.currentState.scrollTo(int position);
 ```
 *Note: position is index in list*
#### 3. Graph Params
 - Points of Graph. Array of [GraphPoint(x: value, y: value)]<br/>
```List<GraphPoint> graphPoints```
 - Left (X) widget offset.
Default is 0.0.<br/>
```double left```
 - Top (Y) widget offset.
Default is 0.0.<br/>
```double top```
 - Additional free area for scrolling before Graph.
Default is 0.0.<br/>
```double startOverScroll```
 - Additional free area for scrolling after Graph.
Default is 0.0.<br/>
```double endOverScroll```
 - Count of grid lines at Y coordinate.<br/>
Default is 10.
```int yGridSize```
 - Duration of scroll animation<br/>
in milliseconds
```int scrollDuration```
 - Points radius [double]<br/>
```double pointRadius```
 - Max point at screen at X coordinate
Using only when scrolling is enabled;
To use Y scale size depending on Graph max value - use GraphConst.AUTO.<br/>
```int yScale```
 - Max point of Y coordinate<br/>
```int xScale```
 - Show markings every X value
For example:
showMarkingsEveryX = 5; ,markings = 5,10,15 etc
to enable all markings set showMarkingsEveryX to 0.<br/>
```int showMarkingsEveryX```
 - Enable or disable rounding Graph corners.
Disabled by default.<br/>
```bool enableRoundCorners```
 - Enable or disable fill Graph with paint or Gradient.
Disabled by default.<br/>
```bool enableFill```
 - Enable or disable text markings at the bottom of Graph.
Disabled by default.<br/>
```bool enableMarks```
 - Enable or disable grid.
Disabled by default.<br/>
```bool enableGrid```
 - Enable or disable scrolling.
Disabled by default.<br/>
```bool enableScroll```
 - Enable or disable scroll fling.
Disabled by default.<br/>
```bool enableFling```
 - Enable or disable points.
Disabled by default.<br/>
```bool enablePoints```
 - Widget height.
To use screen height use GraphConst.WRAP.<br/>
```double height```
 - Widget width.
To use screen width use GraphConst.WRAP.<br/>
```double width```
 - Paint of Graph.<br/>
```Paint mainLinePaint```
 - Gradient of Graph paint.<br/>
```Gradient gradient```
 - Paint of Grid.<br/>
```Paint gridPaint```
 - Paint of Point at Graph.<br/>
```Paint pointsPaint```
 - Paint of background.<br/>
```Paint bgdPaint```
 - Paint of Markings background.<br/>
```Paint marksBgdPaint```
 - Markings text style UI.TextStyle.<br/>
```UI.TextStyle textStyle```
 
