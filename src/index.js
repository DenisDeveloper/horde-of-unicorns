import { Elm } from "./Main.elm";

var app = Elm.Main.init({ node: document.getElementById("root") });

// app.ports.toJs.subscribe(v => {
//   console.log(v);
//   app.ports.toElm.send(JSON.stringify(Date.parse(v)));
// });
