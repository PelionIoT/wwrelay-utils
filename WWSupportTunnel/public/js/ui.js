var tunnelUP = false;

function stop() {
	tunnelUP = false;
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

function start() {
	tunnelUP = true;
	$.ajax({
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
    		$("#display-key").html("-----");
    	} else {
    		data = data.replace(/\n/g, "<br />");
    		$("#display-key").html(data);
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
		// disable start, enable stop
		$("#start").prop("disabled", true);
		$("#stop").prop("disabled", false);
		$("#refreshKey").prop("disabled", false);
		$("#refreshPort").prop("disabled", false);
		$("#downloadKey").prop("disabled", false);		
	} else { // tunnel down
		// enable start, disable stop
		$("#start").prop("disabled", false);
		$("#stop").prop("disabled", true);
		$("#refreshKey").prop("disabled", true);
		$("#refreshPort").prop("disabled", true);
		$("#downloadKey").prop("disabled", true);
	}
}

$(document).ready(function() {
	updateButtons();
});