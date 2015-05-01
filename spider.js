var fs = require('fs')
var system = require('system')
var webpage = require('webpage')

courses = JSON.parse(fs.read('courses_basic_info.json'))
baseurl = "http://cmap.cycu.edu.tw:8080/Syllabus/CoursePreview.html?yearTerm=1032&opCode="


url = encodeURI(baseurl + system.args[1]);
var page = webpage.create();

page.onConsoleMessage = function(msg) {
    console.log(msg);
};

page.onError = function (msg, trace) {
    console.log(msg);
    trace.forEach(function(item) {
        console.log('  ', item.file, ':', item.line);
    })
}

page.open(url, function(status){

  if (status !== "success") {
      console.log("Unable to access network");
  }

  else {
    page.injectJs('jquery-2.1.3.min.js');

    textbook = page.evaluate(function() {
      rows = $('table.GALD-WODG[title="教科書"] tr:nth-child(n+3)');
      books = [];
      if (rows.length != 0) {
        for (var i = 0; i < rows.length; i++) {
          book = {}
          cols = $(rows[i]).children('td').children();
          book["name"] = cols[0].innerText;
          book["author"] = cols[1].innerText;
          book["year"] = cols[2].innerText;
          book["publisher"] = cols[3].innerText;
          book["isbn"] = cols[4].innerText;
          book["revision"] = cols[5].innerText;
          books = books.concat(book);
        }
      }
      return books;
    });
    // courses[i]["textbook"] = textbook;
    // console.log(JSON.stringify(courses[i]["textbook"]));
    filename = "book_datas/" + system.args[1] + ".json"
    fs.write(filename, JSON.stringify(textbook, null, 2), 'w');
    phantom.exit()
  }
});
