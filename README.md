
# Flutter GraphWidget


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
 - *Points of Graph. Array of [GraphPoint(x: value, y: value)]*
```List<GraphPoint> graphPoints```
 - *Left (X) widget offset.
Default is 0.0.*
```double left```
 - *Top (Y) widget offset.
Default is 0.0.*
```double top```
 - *Additional free area for scrolling before Graph.
Default is 0.0.*
```double startOverScroll```
 - *Additional free area for scrolling after Graph.
Default is 0.0.*
```double endOverScroll```
 - *Count of grid lines at Y coordinate.
Default is 10.*
```int yGridSize```
 - *Duration of scroll animation
in milliseconds*
```int scrollDuration```
 - *Points radius [double]*
```double pointRadius```
 - *Max point at screen at X coordinate
Using only when scrolling is enabled;
To use Y scale size depending on Graph max value - use GraphConst.AUTO.*
```int yScale```
 - *Max point of Y coordinate*
```int xScale```
 - *Show markings every X value
For example:
showMarkingsEveryX = 5; ,markings = 5,10,15 etc
to enable all markings set showMarkingsEveryX to 0.*
```int showMarkingsEveryX```
 - *Enable or disable rounding Graph corners.
Disabled by default.*
```bool enableRoundCorners```
 - *Enable or disable fill Graph with paint or Gradient.
Disabled by default.*
```bool enableFill```
 - *Enable or disable text markings at the bottom of Graph.
Disabled by default.*
```bool enableMarks```
 - *Enable or disable grid.
Disabled by default.*
```bool enableGrid```
 - *Enable or disable scrolling.
Disabled by default.*
```bool enableScroll```
 - *Enable or disable scroll fling.
Disabled by default.*
```bool enableFling```
 - *Enable or disable points.
Disabled by default.*
```bool enablePoints```
 - *Widget height.
To use screen height use GraphConst.WRAP.*
```double height```
 - *Widget width.
To use screen width use GraphConst.WRAP.*
```double width```
 - *Paint of Graph.*
```Paint mainLinePaint```
 - *Gradient of Graph paint .*
```Gradient gradient```
 - *Paint of Grid.*
```Paint gridPaint```
 - *Paint of Point at Graph.*
```Paint pointsPaint```
 - *Paint of background.*
```Paint bgdPaint```
 - *Paint of Markings background.*
```Paint marksBgdPaint```
 - *Markings text style UI.TextStyle.*
```UI.TextStyle textStyle```
 

