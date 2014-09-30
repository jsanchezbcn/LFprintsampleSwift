LFprintsample Swift
====================

Sample code on how to print to a large format printer with roll from iOS using swift. 

The sample is considering the source PDF as a blueprint. It tries to minimize the amount of waste paper by rotating the drawing and in case scaling is needed, it tries to scale to 50% first.

There is also a usefull playground to "play" with different options when printing, usefull to check how a document will look on differente roll sizes without any need to print and use the simulator. This code could be useful as well to do unit testing code.

There is a sample Arch D size blueprint PDF and two different methods to print it.

1. Using UIPrintInteractionController and printingItem. The control in this case is limited but the integration is easy.

2. Using a UIPrintPageRenderer, so you have a full control on how the PDF will be printed on the paper. I recommend to use this method. 

On this case when printing a D size 24x36inches, the result will be like:

* Printing on a 36inches roll: Printed landscape and no scaling.
* Printing on a 24inches roll: Printed portrait and no scaling.
* Printing to a 17inches roll: Printed in portrait at 50% scale and with a "Halfsize" watermark.
* Printing on a B size sheet: Printed in portrait at 50% scale with a "halfsize" watermark.
* Printing on a A size sheet: will be printed scale to sheet.


There is available a version of this code made on [Objective-C](http://github.com/jsanchezbcn/LFprintsample). 



