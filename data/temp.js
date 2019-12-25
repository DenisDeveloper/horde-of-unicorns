const fs = require("fs");

const ruDateToEn = date => date.replace(/(\d{2}).(\d{2}).(\d{4})/, "$2.$1.$3");

fs.readFile("input.json", "utf8", (err, data) => {
  let res = JSON.parse(data).map(job => {
    let start = ruDateToEn(job.start);
    let finish = ruDateToEn(job.finish);
    return { ...job, start: Date.parse(start), finish: Date.parse(finish) };
  });
  fs.writeFile("jobs.json", JSON.stringify(res), err => {
    console.log("done");
  });
  console.log(data);
});
