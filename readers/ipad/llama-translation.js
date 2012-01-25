var ltcanvas = {};



// touch handling code! thanks http://ross.posterous.com/2008/08/19/iphone-touch-events-in-javascript/
function touchHandler(event)
{
    var touches = event.changedTouches,
        first = touches[0],
        type = "";
         switch(event.type)
    {
        case "touchstart": type = "mousedown"; break;
        case "touchmove":  type="mousemove"; break;
        case "touchend":   type="mouseup"; break;
        default: return;
    }

             //initMouseEvent(type, canBubble, cancelable, view, clickCount,
    //           screenX, screenY, clientX, clientY, ctrlKey,
    //           altKey, shiftKey, metaKey, button, relatedTarget);

    var simulatedEvent = document.createEvent("MouseEvent");
    simulatedEvent.initMouseEvent(type, true, true, window, 1,
                              first.screenX, first.screenY,
                              first.clientX, first.clientY, false,
                              false, false, false, 0/*left*/, null);

                                                                                 first.target.dispatchEvent(simulatedEvent);
    event.preventDefault();
}

function init() {
    var c=document.getElementById("llama-translation-interactive");
    var context=c.getContext("2d");
    c.addEventListener("click", get_mouse_event_click, false);
    c.addEventListener("mousedown", get_mouse_event_mousedown, false);
    c.addEventListener("mouseup", get_mouse_event_mouseup, false);
    ltcanvas.c = c;
    ltcanvas.context = context;
    ltcanvas.mousedownflag = 0;
    ltcanvas.anymouseeventflag = 0;
    ltcanvas.mousex = 0;
    ltcanvas.mousey = 0;
    ltcanvas.isx = 0;
    ltcanvas.isy = 0;  // "image space" x and y
    ltcanvas.matrix = [1,0,0,0,1,0,0,0,1];
    ltcanvas.frameLock = 0;
	
	// coord plane background
	ltcanvas.coords = new Image();
	//ltcanvas.coords.src = "/Users/snapp/textbook/html/images/coord_plane-trans.png";
    ltcanvas.coords.src = "coord_plane-trans.png";

    
    
	//initialize llama image resource
	ltcanvas.llama = new Image();
    ltcanvas.llama.src = "llama.png";

    // touch handling code!
    ltcanvas.c.addEventListener("touchstart", touchHandler, true);
    ltcanvas.c.addEventListener("touchmove", touchHandler, true);
    ltcanvas.c.addEventListener("touchend", touchHandler, true);
    ltcanvas.c.addEventListener("touchcancel", touchHandler, true);
}

function get_mouse_event_click(e) {
   return;
};

function get_mouse_event_mousedown(e) {
   ltcanvas.mousedownflag = 1;
   ltcanvas.anymouseeventflag = 1;
   ltcanvas.mousex = e.pageX-ltcanvas.c.offsetLeft;
   ltcanvas.mousey = e.pageY-ltcanvas.c.offsetTop;
   var ix, iy;
    ix = ltcanvas.mousex - 199;
    iy = ltcanvas.mousey - 199;
    iy = iy * -1;
    ltcanvas.isx = ix;
    ltcanvas.isy = iy;
   draw_llama_instance();
   ltcanvas.c.addEventListener("mousemove", get_mouse_event_mousemove, false);
};

function get_mouse_event_mouseup(e) {
   ltcanvas.mousedownflag = 0;
   ltcanvas.anymouseeventflag = 1;
   ltcanvas.mousex = e.pageX-ltcanvas.c.offsetLeft;
   ltcanvas.mousey = e.pageY-ltcanvas.c.offsetTop;
   var ix, iy;
    ix = ltcanvas.mousex - 199;
    iy = ltcanvas.mousey - 199;
    iy = iy * -1;
    ltcanvas.isx = ix;
    ltcanvas.isy = iy;
   draw_llama_instance();
   ltcanvas.c.removeEventListener("mousemove", get_mouse_event_mousemove, false);
};

function get_mouse_event_mousemove(e) {
   if (ltcanvas.mousedownflag == 0) {
       return;
   }
   else if (ltcanvas.frameLock == 1) {
       return;
   }
   else {
        ltcanvas.anymouseeventflag = 1;
        ltcanvas.mousex = e.pageX-ltcanvas.c.offsetLeft;
        ltcanvas.mousey = e.pageY-ltcanvas.c.offsetTop;
        var ix, iy;
        ix = ltcanvas.mousex - 199;
        iy = ltcanvas.mousey - 199;
        iy = iy * -1;
        ltcanvas.isx = ix;
        ltcanvas.isy = iy;

        draw_llama_instance();
   }
};


function draw_llama(x, y) {
    // convert llama coords from image coords to canvas coords
    // coord plane center is at 349, 349
    var cx, cy;
    cy = y * -1;
    cx = x + 199 - 40;
    cy = cy + 199 - 50;
     // screen y's have positive pointing down, coord plane is up
    // so we have to invert the y amount after adjusting


    ltcanvas.context.drawImage(ltcanvas.llama, cx, cy);
};

function update_matrix(x,y) {
    ltcanvas.matrix = [1,0,x/10,0,1,y/10,0,0,1];
};
function draw_matrix() {
    var cx = ltcanvas.context;
    cx.beginPath();
    cx.moveTo(410,100);
    cx.lineTo(400,100);
    cx.lineTo(400,215);
    cx.lineTo(410,215);

    cx.moveTo(530,100);
    cx.lineTo(540,100);
    cx.lineTo(540,215);
    cx.lineTo(530,215);

    cx.strokeStyle = "#000";
    cx.stroke();

    // now fill in text
    cx.font = "bold 24px serif"
    cx.fillText(ltcanvas.matrix[0], 425,125);
    cx.fillText(ltcanvas.matrix[1], 455,125);
    cx.fillText(ltcanvas.matrix[2], 485,125);
    cx.fillText(ltcanvas.matrix[3], 425,165);
    cx.fillText(ltcanvas.matrix[4], 455,165);
    cx.fillText(ltcanvas.matrix[5], 485,165);
    cx.fillText(ltcanvas.matrix[6], 425,204);
    cx.fillText(ltcanvas.matrix[7], 455,204);
    cx.fillText(ltcanvas.matrix[8], 485,204);


};

var llama_deg = 0;
// draws a single llama instance then waits before drawing the next
// uses above global variables for instance counting
function draw_llama_instance() {
    ltcanvas.frameLock = 1;
    setTimeout(function () { ltcanvas.frameLock = 0; }, 33)
        if (ltcanvas.anymouseeventflag == 0)
        {
            ltcanvas.c.width = ltcanvas.c.width; // reset canvas
			ltcanvas.context.drawImage(ltcanvas.coords, 0, 0);
			draw_llama(0,0);
            draw_matrix();
        }
        else
        {
            // first, do bounds checks
            if (ltcanvas.isx > 150) { ltcanvas.isx = 150; }
            if (ltcanvas.isy > 150) { ltcanvas.isy = 150; }
            if (ltcanvas.isx < -150) { ltcanvas.isx = -150; }
            if (ltcanvas.isy < -150) { ltcanvas.isy = -150; }
            update_matrix(ltcanvas.isx, ltcanvas.isy);
			ltcanvas.c.width = ltcanvas.c.width; // reset canvas
			ltcanvas.context.drawImage(ltcanvas.coords, 0, 0);
            draw_llama(ltcanvas.isx, ltcanvas.isy);
            draw_matrix();

        }
	
};


init();
draw_llama_instance(ltcanvas.c, ltcanvas.context);
