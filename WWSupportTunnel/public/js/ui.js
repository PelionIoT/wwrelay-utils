var tunnelUP = false;

function stopTun() {
	$.ajax({
	  url: "/stop",
	  context: document.body
	});
	setTimeout(function(){
		displayKey();
		displayPort();
	}, 3000);
    updateButtons();
}

function startTun() {	$.ajax({
	  url: "/start",
	  context: document.body
	});
	setTimeout(function(){
		keyInterval = setInterval(
			function(){
				displayKey();
			}, 
		1000);

		portInterval = setInterval(
			function(){
				displayPort();
			}, 
		1000);

	}, 1000);
	updateButtons();
}

function startstop(){
	if (tunnelUP){
		tunnelUP = false;
		stopTun();
	} else {
		tunnelUP = true;
		startTun();
	}
}

function download() {
	console.log('stuff');
	$.ajax({
	  url: "/downloadKey",
	  context: document.body
	});
}

function displayKey(){
	$.get("/returnKey", function(data){
		if (data === "" || data === undefined){
    		// empty can see
    		// full gone
    		$("#display-empty-key").css("display", "block");
    		$("#display-full-key").css("display", "none");
    	} else {

    		// data = data.replace(/\n/g, "<br />");
    		// empty gone
    		// full can see
    		$("#display-empty-key").css("display", "none");
    		$("#display-full-key").css("display", "block");
    		$('#display-full-key').val(data);
    		clearInterval(keyInterval);
    	}
    	console.log(data + "asdfasdf");
	});
}

function displayPort(){
	$.get("/returnPort", function(data){
		var dataNumber = parseInt(data, 10)
		if (dataNumber <= 0 || data === undefined){
    		$("#display-port").html("#####");
    	} else {
    		$("#display-port").html(data);
    		clearInterval(portInterval);
    	}
    	console.log(dataNumber + "fdsafdsa");
	});
}


function updateButtons(){
	if (tunnelUP){ // tunnel up yay
		// display stop
		
		$("#downloadKey").prop("disabled", false);		
	} else { // tunnel down
		// display to start
		$("#downloadKey").prop("disabled", true);
	}
}

$(document).ready(function() {
	updateButtons();
});