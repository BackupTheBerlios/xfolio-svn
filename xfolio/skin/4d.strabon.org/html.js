/*
SDX: Documentary System in XML.
Copyright : (C) 2000, 2001, 2002, 2003, 2004 Ministere de la culture et de la communication (France), AJLSM
Licence   : http://www.fsf.org/copyleft/gpl.html
frederic.glorieux@ajlsm.com

some default javascript from different sources, worked under different contexts

*/


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
	if (side) side.style.pixelTop=document.body.scrollTop+100; 
        if (!footer)
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
        // if (header.style) header.style.position='absolute';
	// if (document.side) if (side.style) side.style.position='absolute';
	// if (document.footer) if (footer.style) footer.style.position='absolute';
	// window.onscroll=fixed;
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
	// set a max
	ratio=(ratio > 200)?200:ratio;
	document.body.style.fontSize=ratio+'%';
	if (!document.getElementById) return false;
}


