/*
get properties of an object
for debug
*/
function props(o) {
   var result = ""
   var a=new Array();
   var i=0
   for (var prop in o) {
      a[i]= prop  + "\t"; // + " = " + o[prop]
      i++;
   }
   a.sort();
   return a;
}


/*
Simulate the css position:fixed property for IE
Should be deprecated

assume we have a header, side, and footer object
in our case, div with id
*/

function fixed() {
	if (!document.all) return;
	side.style.pixelTop=document.body.scrollTop+100; 
	if (!footer) return;
	footer.style.display='none'; 
	footer.style.bottom='0px'; 
	footer.style.display=''; 
}

/*
Fit character size to width of screen
Prepare the fixed() simulate for IE
Means, set position:absolute to the fixed elements
*/

function init() {
	fit(90);
	if (!document.all) return;
// 	if (header.style) header.style.position='absolute';
	if (window.side) if (side.style) side.style.position='absolute';
	if (window.footer) if (footer.style) footer.style.position='absolute';
	window.onscroll=fixed;
}

/*
Maintain a fixed number of character on the width of the window

*/

// normal pixel height
var fontSizeNormal=16;
var widthDefault=80;
if ( document.getElementById && !document.all ) var fontSizeNormal=12; // may be mozilla

function fit(ex) {

  // fit char size  
  var width;
  if (document.body.offsetWidth) width=document.body.offsetWidth;
  if (document.body.clientWidth) width=document.body.clientWidth;
  else return false;
  
  if (!ex) var ex=widthDefault;
  // default ratio between ex and em 
  fontSizeFit=(width/ex)*1.2;
  ratio=Math.round ( fontSizeFit / fontSizeNormal  * 100);
  // set a minimum ratio under which the page may be unreadable
  ratio=(ratio < 50)?50:ratio;
  document.body.style.fontSize=ratio+'%';
  if (!document.getElementById) return false;
}


