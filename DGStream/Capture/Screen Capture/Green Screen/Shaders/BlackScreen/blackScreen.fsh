//
//  greenScreen.fsh
//  GreenScreen
//
/*
Copyright (c) 2012 Erik M. Buck

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

varying highp vec2 vCoordinate;
uniform sampler2D uVideoframe;
uniform highp mat4 uMVPMatrix;

// BLACK
void main()
{
    lowp vec4 tempColor = texture2D(uVideoframe, vCoordinate);
    lowp float rgbAverage = tempColor.r + tempColor.b + tempColor.g;
    if (rgbAverage < 0.60) {
        tempColor.a = 0.0;
    }
    else if (rgbAverage < 0.75) {
        tempColor.a = 0.75;
    }
    else {
        tempColor.a = 1.0;
    }
    gl_FragColor = tempColor;
}
