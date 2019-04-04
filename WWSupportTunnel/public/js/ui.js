/*
 * Copyright (c) 2018, Arm Limited and affiliates.
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
    		$("#display-full-key").val("No Key");
    	} else {

    		// data = data.replace(/\n/g, "<br />");
    		// empty gone
    		// full can see
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
		$("#innerbutton").css("background-color", "#0094D9");
		$("#downloadKey").css("opacity", "1");		
	} else { // tunnel down
		// display start
		$("#innerbutton").css("background-color", "#C8C8C8");
		$("#downloadKey").css("opacity", "0.3");
	}
}

$(document).ready(function() {
	updateButtons();
});