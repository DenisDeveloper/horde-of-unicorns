import { Elm } from "./Main.elm";

var app = Elm.Main.init({ node: document.getElementById("root") });

// app.ports.toJs.subscribe(v => {
//   console.log(v);
//   app.ports.toElm.send(JSON.stringify(Date.parse(v)));
// });

// const recalcConversion = (start, end, contentWidth) => {
//   let offset = Date.parse(start);
//   let factor = contentWidth / (Date.parse(end) - Date.parse(start));
//   return { offset, factor };
// };

const s = 1516306657000;
const e = 1579378808000;

const recalcConversion = (start, end, contentWidth) => {
  let offset = start;
  let factor = contentWidth / (end - start);
  return { offset, factor };
};

let c = recalcConversion(s, e, 1396);
// console.log("calc js", c);

const screenToTime = (x, conversion) => {
  return new Date(x / conversion.factor + conversion.offset);
};

const timeToScreen = (ms, conversion) => {
  return (ms - conversion.offset) * conversion.factor;
};

// todo: calc char width
const characterMinorWidth = 7.81;

const minimumStep =
  screenToTime(characterMinorWidth * 6, c) - screenToTime(0, c);



const setVisibleChartRangeAuto = () => {
  let range = getMarginRange(s, e);
};

const applyRange = (start, end, zoomAroundDate) => {
    // calculate new start and end value
    var startValue = start.valueOf(); // number
    var endValue = end.valueOf();     // number
    var interval = (endValue - startValue);

    // determine maximum and minimum interval
    var options = this.options;
    var year = 1000 * 60 * 60 * 24 * 365;
    var zoomMin = Number(options.zoomMin) || 10;
    if (zoomMin < 10) {
        zoomMin = 10;
    }
    var zoomMax = Number(options.zoomMax) || 10000 * year;
    if (zoomMax > 10000 * year) {
        zoomMax = 10000 * year;
    }
    if (zoomMax < zoomMin) {
        zoomMax = zoomMin;
    }

    // determine min and max date value
    var min = options.min ? options.min.valueOf() : undefined; // number
    var max = options.max ? options.max.valueOf() : undefined; // number
    if (min != undefined && max != undefined) {
        if (min >= max) {
            // empty range
            var day = 1000 * 60 * 60 * 24;
            max = min + day;
        }
        if (zoomMax > (max - min)) {
            zoomMax = (max - min);
        }
        if (zoomMin > (max - min)) {
            zoomMin = (max - min);
        }
    }

    // prevent empty interval
    if (startValue >= endValue) {
        endValue += 1000 * 60 * 60 * 24;
    }

    // prevent too small scale
    // TODO: IE has problems with milliseconds
    if (interval < zoomMin) {
        var diff = (zoomMin - interval);
        var f = zoomAroundDate ? (zoomAroundDate.valueOf() - startValue) / interval : 0.5;
        startValue -= Math.round(diff * f);
        endValue   += Math.round(diff * (1 - f));
    }

    // prevent too large scale
    if (interval > zoomMax) {
        var diff = (interval - zoomMax);
        var f = zoomAroundDate ? (zoomAroundDate.valueOf() - startValue) / interval : 0.5;
        startValue += Math.round(diff * f);
        endValue   -= Math.round(diff * (1 - f));
    }

    // prevent to small start date
    if (min != undefined) {
        var diff = (startValue - min);
        if (diff < 0) {
            startValue -= diff;
            endValue -= diff;
        }
    }

    // prevent to large end date
    if (max != undefined) {
        var diff = (max - endValue);
        if (diff < 0) {
            startValue += diff;
            endValue += diff;
        }
    }

    // apply new dates
    this.start = new Date(startValue);
    this.end = new Date(endValue);
};


const getMarginRange = (start, end) => {
  // zoom out 5% such that you have a little white space on the left and right
  let diff = (end - start);
  let min = start - diff * 0.05;
  let max = end + diff * 0.05;

  return {min, max};
};

console.log("margin range", getMarginRange(1578792563000, 1579829330000));

// .vis-time-axis .vis-text.vis-measure {
//   position: absolute;
//   padding-left: 0;
//   padding-right: 0;
//   margin-left: 0;
//   margin-right: 0;
//   visibility: hidden;
// }

// const _calculateCharSize = () => {
//   // Note: We calculate char size with every redraw. Size may change, for
//   // example when any of the timelines parents had display:none for example.
//
//   // determine the char width and height on the minor axis
//   if (!this.dom.measureCharMinor) {
//     this.dom.measureCharMinor = document.createElement("DIV");
//     this.dom.measureCharMinor.className = "vis-text vis-minor vis-measure";
//     this.dom.measureCharMinor.style.position = "absolute";
//
//     this.dom.measureCharMinor.appendChild(document.createTextNode("0"));
//     this.dom.foreground.appendChild(this.dom.measureCharMinor);
//   }
//   this.props.minorCharHeight = this.dom.measureCharMinor.clientHeight;
//   this.props.minorCharWidth = this.dom.measureCharMinor.clientWidth;
//
//   // determine the char width and height on the major axis
//   if (!this.dom.measureCharMajor) {
//     this.dom.measureCharMajor = document.createElement("DIV");
//     this.dom.measureCharMajor.className = "vis-text vis-major vis-measure";
//     this.dom.measureCharMajor.style.position = "absolute";
//
//     this.dom.measureCharMajor.appendChild(document.createTextNode("0"));
//     this.dom.foreground.appendChild(this.dom.measureCharMajor);
//   }
//   this.props.majorCharHeight = this.dom.measureCharMajor.clientHeight;
//   this.props.majorCharWidth = this.dom.measureCharMajor.clientWidth;
// };

// let StepDate = (start, end, minimumStep) => {
//   // variables
//   // this.current = new Date();
//   // this._start = new Date();
//   // this._end = new Date();
//   //
//   // this.autoScale  = true;
//   // this.scale = links.Timeline.StepDate.SCALE.DAY;
//   // this.step = 1;
//
//   // initialize the range
//   setRange(start, end, minimumStep);
// };

/// enum scale
const SCALE = {
  MILLISECOND: 1,
  SECOND: 2,
  MINUTE: 3,
  HOUR: 4,
  DAY: 5,
  WEEKDAY: 6,
  MONTH: 7,
  YEAR: 8
};

const setRange = (start, end, minimumStep) => {
  if (!(start instanceof Date) || !(end instanceof Date)) {
    //throw  "No legal start or end date in method setRange";
    return;
  }

  this._start = start != undefined ? new Date(start.valueOf()) : new Date();
  this._end = end != undefined ? new Date(end.valueOf()) : new Date();

  if (this.autoScale) {
    this.setMinimumStep(minimumStep);
  }
};

const repaintAxis = () => {
  let start = screenToTime(0, c);
  let end = screenToTime(contentWidth, c);

  // calculate minimum step (in milliseconds) based on character size
  if (characterMinorWidth) {
    let minimumStep =
      screenToTime(characterMinorWidth * 6, c) -
      screenToTime(0, c);

    step.setRange(start, end, minimumStep);
  }

  // var charsNeedsReflow = this.repaintAxisCharacters();

  // The current labels on the axis will be re-used (much better performance),
  // therefore, the repaintAxis method uses the mechanism with
  // repaintAxisStartOverwriting, repaintAxisEndOverwriting, and
  // this.size.axis.properties is used.
  // this.repaintAxisStartOverwriting();

  step.start();
  var xFirstMajorLabel = undefined;
  var max = 0;
  while (!step.end() && max < 1000) {
    max++;
    var cur = step.getCurrent(),
      x = this.timeToScreen(cur),
      isMajor = step.isMajor();

    if (options.showMinorLabels) {
      this.repaintAxisMinorText(x, step.getLabelMinor(options));
    }

    if (isMajor && options.showMajorLabels) {
      if (x > 0) {
        if (xFirstMajorLabel == undefined) {
          xFirstMajorLabel = x;
        }
        this.repaintAxisMajorText(x, step.getLabelMajor(options));
      }
      this.repaintAxisMajorLine(x);
    } else {
      this.repaintAxisMinorLine(x);
    }

    step.next();
  }

  // create a major label on the left when needed
  if (options.showMajorLabels) {
    var leftTime = this.screenToTime(0),
      leftText = this.step.getLabelMajor(options, leftTime),
      width = leftText.length * size.axis.characterMajorWidth + 10; // upper bound estimation

    if (xFirstMajorLabel == undefined || width < xFirstMajorLabel) {
      this.repaintAxisMajorText(0, leftText, leftTime);
    }
  }

  // cleanup left over labels
  this.repaintAxisEndOverwriting();

  this.repaintAxisHorizontal();

  // put axis online
  dom.content.insertBefore(axis.frame, dom.content.firstChild);

  return needsReflow;
};

const roundToMinor = (scale, step, current) => {
  switch (scale) {
    case SCALE.YEAR:
      current.setFullYear(step * Math.floor(current.getFullYear() / step));
      current.setMonth(0);
    case SCALE.MONTH:
      current.setDate(1);
    case SCALE.DAY: // intentional fall through
    case SCALE.WEEKDAY:
      current.setHours(0);
    case SCALE.HOUR:
      current.setMinutes(0);
    case SCALE.MINUTE:
      current.setSeconds(0);
    case SCALE.SECOND:
      current.setMilliseconds(0);
  }

  if (step != 1) {
    switch (scale) {
      case SCALE.MILLISECOND:
        current.setMilliseconds(
          current.getMilliseconds() - (current.getMilliseconds() % step)
        );
        break;
      case SCALE.SECOND:
        current.setSeconds(
          current.getSeconds() - (current.getSeconds() % step)
        );
        break;
      case SCALE.MINUTE:
        current.setMinutes(
          current.getMinutes() - (current.getMinutes() % step)
        );
        break;
      case SCALE.HOUR:
        current.setHours(current.getHours() - (current.getHours() % step));
        break;
      case SCALE.WEEKDAY: // intentional fall through
      case SCALE.DAY:
        current.setDate(
          current.getDate() - 1 - ((current.getDate() - 1) % step) + 1
        );
        break;
      case SCALE.MONTH:
        current.setMonth(current.getMonth() - (current.getMonth() % step));
        break;
      case SCALE.YEAR:
        current.setFullYear(
          current.getFullYear() - (current.getFullYear() % step)
        );
        break;
      default:
        break;
    }
  }
  return current;
};

// console.log("rtm", roundToMinor(6, 1, new Date(1579727404000)));

const start = (scale, step, start) =>
  roundToMinor(scale, step, new Date(start));

const end = (current, end) => {
  return current > end;
};

const next = (current, scale, step, end) => {
  let prev = Date.parse(current);
  let temp = new Date(current);
  // console.log("month", current.getMonth());
  // console.log("next", current);
  // Two cases, needed to prevent issues with switching daylight savings
  // (end of March and end of October)
  if (current.getMonth() < 6) {
    // console.log("1");
    switch (scale) {
      case SCALE.MILLISECOND:
        console.log("ms");
        temp = new Date(current.valueOf() + step);
        break;
      case SCALE.SECOND:
        console.log("sec");
        temp = new Date(current.valueOf() + step * 1000);
        break;
      case SCALE.MINUTE:
        console.log("minute");
        temp = new Date(current.valueOf() + step * 1000 * 60);
        break;
      case SCALE.HOUR:
        console.log("hour");
        temp = new Date(current.valueOf() + step * 1000 * 60 * 60);
        // in case of skipping an hour for daylight savings, adjust the hour again (else you get: 0h 5h 9h ... instead of 0h 4h 8h ...)
        let h = temp.getHours();
        temp.setHours(h - (h % step));
        break;
      case SCALE.WEEKDAY: // intentional fall through
      case SCALE.DAY:
        console.log("day");
        temp.setDate(current.getDate() + step);
        break;
      case SCALE.MONTH:
        // console.log("month");
        // console.log("js cur month", current.getMonth() + step);
        temp.setMonth(current.getMonth() + step);
        break;
      case SCALE.YEAR:
        console.log("year");
        temp.setFullYear(current.getFullYear() + step);
        break;
      default:
        break;
    }
  } else {
    // console.log("2");
    switch (scale) {
      case SCALE.MILLISECOND:
        temp = new Date(current.valueOf() + step);
        break;
      case SCALE.SECOND:
        temp.setSeconds(current.getSeconds() + step);
        break;
      case SCALE.MINUTE:
        temp.setMinutes(current.getMinutes() + step);
        break;
      case SCALE.HOUR:
        temp.setHours(current.getHours() + step);
        break;
      case SCALE.WEEKDAY: // intentional fall through
      case SCALE.DAY:
        temp.setDate(current.getDate() + step);
        break;
      case SCALE.MONTH:
        temp.setMonth(current.getMonth() + step);
        break;
      case SCALE.YEAR:
        temp.setFullYear(current.getFullYear() + step);
        break;
      default:
        break;
    }
  }

  if (step != 1) {
    // console.log("3");
    // round down to the correct major value
    switch (scale) {
      case SCALE.MILLISECOND:
        console.log("ms");
        if (temp.getMilliseconds() < step) temp.setMilliseconds(0);
        break;
      case SCALE.SECOND:
        console.log("sec");
        if (temp.getSeconds() < step) temp.setSeconds(0);
        break;
      case SCALE.MINUTE:
        console.log("minute");
        if (temp.getMinutes() < step) temp.setMinutes(0);
        break;
      case SCALE.HOUR:
        console.log("hour");
        if (temp.getHours() < step) temp.setHours(0);
        break;
      case SCALE.WEEKDAY: // intentional fall through
      case SCALE.DAY:
        console.log("day");
        if (temp.getDate() < step + 1) temp.setDate(1);
        break;
      case SCALE.MONTH:
        // console.log("month");
        if (temp.getMonth() < step) temp.setMonth(0);
        break;
      case SCALE.YEAR:
        console.log("year");
        break; // nothing to do for year
      default:
        break;
    }
  }

  // safety mechanism: if current time is still unchanged, move to the end
  if (temp.valueOf() == prev) {
    temp = new Date(end.valueOf());
  }
  return temp;
};

const setMinimumStep = minimumStep => {
  if (minimumStep == undefined) {
    return;
  }

  let scale = SCALE.DAY;
  let step = 1;

  let stepYear = 1000 * 60 * 60 * 24 * 30 * 12;
  let stepMonth = 1000 * 60 * 60 * 24 * 30;
  let stepDay = 1000 * 60 * 60 * 24;
  let stepHour = 1000 * 60 * 60;
  let stepMinute = 1000 * 60;
  let stepSecond = 1000;
  let stepMillisecond = 1;

  // find the smallest step that is larger than the provided minimumStep
  if (stepYear * 1000 > minimumStep) {
        scale = SCALE.YEAR;
    step = 1000;
  }
  if (stepYear * 500 > minimumStep) {
        scale = SCALE.YEAR;
    step = 500;
  }
  if (stepYear * 100 > minimumStep) {
        scale = SCALE.YEAR;
    step = 100;
  }
  if (stepYear * 50 > minimumStep) {
        scale = SCALE.YEAR;
    step = 50;
  }
  if (stepYear * 10 > minimumStep) {
        scale = SCALE.YEAR;
    step = 10;
  }
  if (stepYear * 5 > minimumStep) {
        scale = SCALE.YEAR;
    step = 5;
  }
  if (stepYear > minimumStep) {
        scale = SCALE.YEAR;
    step = 1;
  }
  if (stepMonth * 3 > minimumStep) {
        scale = SCALE.MONTH;
    step = 3;
  }
  if (stepMonth > minimumStep) {
        scale = SCALE.MONTH;
    step = 1;
  }
  if (stepDay * 5 > minimumStep) {

    scale = SCALE.DAY;
    step = 5;
  }
  if (stepDay * 2 > minimumStep) {

    scale = SCALE.DAY;
    step = 2;
  }
  if (stepDay > minimumStep) {

    scale = SCALE.DAY;
    step = 1;
  }
  if (stepDay / 2 > minimumStep) {

    scale = SCALE.WEEKDAY;
    step = 1;
  }
  if (stepHour * 4 > minimumStep) {

    scale = SCALE.HOUR;
    step = 4;
  }
  if (stepHour > minimumStep) {

    scale = SCALE.HOUR;
    step = 1;
  }
  if (stepMinute * 15 > minimumStep) {

    scale = SCALE.MINUTE;
    step = 15;
  }
  if (stepMinute * 10 > minimumStep) {

    scale = SCALE.MINUTE;
    step = 10;
  }
  if (stepMinute * 5 > minimumStep) {

    scale = SCALE.MINUTE;
    step = 5;
  }
  if (stepMinute > minimumStep) {

    scale = SCALE.MINUTE;
    step = 1;
  }
  if (stepSecond * 15 > minimumStep) {

    scale = SCALE.SECOND;
    step = 15;
  }
  if (stepSecond * 10 > minimumStep) {

    scale = SCALE.SECOND;
    step = 10;
  }
  if (stepSecond * 5 > minimumStep) {

    scale = SCALE.SECOND;
    step = 5;
  }
  if (stepSecond > minimumStep) {

    scale = SCALE.SECOND;
    step = 1;
  }
  if (stepMillisecond * 200 > minimumStep) {

    scale = SCALE.MILLISECOND;
    step = 200;
  }
  if (stepMillisecond * 100 > minimumStep) {

    scale = SCALE.MILLISECOND;
    step = 100;
  }
  if (stepMillisecond * 50 > minimumStep) {

    scale = SCALE.MILLISECOND;
    step = 50;
  }
  if (stepMillisecond * 10 > minimumStep) {

    scale = SCALE.MILLISECOND;
    step = 10;
  }
  if (stepMillisecond * 5 > minimumStep) {

    scale = SCALE.MILLISECOND;
    step = 5;
  }
  if (stepMillisecond > minimumStep) {

    scale = SCALE.MILLISECOND;
    step = 1;
  }
  return { scale, step };
};

const repaintAxisCharacters = () => {
  // calculate the width and height of a single character
  // this is used to calculate the step size, and also the positioning of the
  // axis
  var needsReflow = false,
    dom = this.dom,
    axis = dom.axis,
    text;

  if (!axis.characterMinor) {
    text = document.createTextNode("0");
    var characterMinor = document.createElement("DIV");
    characterMinor.className = "timeline-axis-text timeline-axis-text-minor";
    characterMinor.appendChild(text);
    characterMinor.style.position = "absolute";
    characterMinor.style.visibility = "hidden";
    characterMinor.style.paddingLeft = "0px";
    characterMinor.style.paddingRight = "0px";
    axis.frame.appendChild(characterMinor);

    axis.characterMinor = characterMinor;
    needsReflow = true;
  }

  if (!axis.characterMajor) {
    text = document.createTextNode("0");
    var characterMajor = document.createElement("DIV");
    characterMajor.className = "timeline-axis-text timeline-axis-text-major";
    characterMajor.appendChild(text);
    characterMajor.style.position = "absolute";
    characterMajor.style.visibility = "hidden";
    characterMajor.style.paddingLeft = "0px";
    characterMajor.style.paddingRight = "0px";
    axis.frame.appendChild(characterMajor);

    axis.characterMajor = characterMajor;
    needsReflow = true;
  }

  return needsReflow;
};

const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
const MONTHS_SHORT = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
const DAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
const DAYS_SHORT = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

const addZeros = (value, len) => {
    let str = "" + value;
    while (str.length < len) {
        str = "0" + str;
    }
    return str;
};

// const getLabelMinor = (options, date) => {
//     if (date == undefined) {
//         date = this.current;
//     }
//
//     switch (this.scale) {
//         case SCALE.MILLISECOND:  return String(date.getMilliseconds());
//         case SCALE.SECOND:       return String(date.getSeconds());
//         case SCALE.MINUTE:
//             return this.addZeros(date.getHours(), 2) + ":" + this.addZeros(date.getMinutes(), 2);
//         case SCALE.HOUR:
//             return this.addZeros(date.getHours(), 2) + ":" + this.addZeros(date.getMinutes(), 2);
//         case SCALE.WEEKDAY:      return options.DAYS_SHORT[date.getDay()] + ' ' + date.getDate();
//         case SCALE.DAY:          return String(date.getDate());
//         case SCALE.MONTH:        return options.MONTHS_SHORT[date.getMonth()];   // month is zero based
//         case SCALE.YEAR:         return String(date.getFullYear());
//         default:                                         return "";
//     }
// };


const minStep = setMinimumStep(minimumStep);

// console.log("js Scale", minStep);

let cur = start(minStep.scale, minStep.step, s);
// console.log("start", cur);

// console.log("start", new Date(s));
// console.log("end", new Date(e));
// console.log("current start", timeToScreen(Date.parse(cur), c));
const c1 = next(cur, minStep.scale, minStep.step, new Date(e));
// const c2 = next(c1, minStep.scale, minStep.step, new Date(e));
// const c3 = next(c2, minStep.scale, minStep.step, new Date(e));
// const c4 = next(c3, minStep.scale, minStep.step, new Date(e));
//
// console.log("c1", c1);
// console.log("c2", c2);
// console.log("c3", c3);
// console.log("c4", c4);
// console.log("next", next(cur, minStep.scale, minStep.step, new Date(e)));

// while (!end(Date.parse(cur), e)) {
//   cur = next(cur, minStep.scale, minStep.step, new Date(e));
//   console.log(timeToScreen(Date.parse(cur), c));
// }

// console.log("test", screenToTime(0, c));

// console.log(end(cur, e));
