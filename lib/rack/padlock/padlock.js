var startTime = Date.now();
var timeOut = 10000;
console.log('Padlock: JS client starting!');
var page = require('webpage').create(),
    system = require('system'),
    t, address;

if (system.args.length === 1) {
    console.log('ERROR: You need to pass phantomjs some URLs to visit!');
    phantom.exit();
}

var pagesToVisit = system.args.slice(1);
var numberOfPagesToVisit = pagesToVisit.length;
var numberOfPagesVisited = 0;

var visitPages = function(pages){
  if(pages.length == 0){return;}
  var thePage = pages.pop();
  console.log("Opening " + thePage);
  page.open(thePage, function (status) {
      if (status !== 'success') {
          console.log('FAIL to load the address: ' + thePage);
      } else {
          console.log('visited: ' + thePage );
      }
      numberOfPagesVisited++;
      visitPages(pages);
  });
};

var exitWhenDone = function(){
  var executionTime = Date.now() - startTime;
  if (numberOfPagesVisited == numberOfPagesToVisit || executionTime > timeOut) {
    phantom.exit();
  } else{
    setTimeout(exitWhenDone,500); 
  }
};

visitPages(pagesToVisit);
exitWhenDone();
