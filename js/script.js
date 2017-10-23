/*
* Ilan Kleiman
* script.js
* 10/23/17
*/

$(document).ready(function() {
	var differentTypes;

	var load_it = function() {
		$.ajax({
			method: "GET",
			url: "howmuch?type=all"
		}).done(function( data ) {
			var json = JSON.parse(data);
			for (var i = 0; i < (differentTypes.types).length; i++) {
				$("#" + differentTypes.types[i] + "_current").html( json[differentTypes.types[i]] );
			}
		});
		setTimeout(load_it, 2000);
	}

// starter
	$.ajax({
		method: "GET",
		url: "../types/types.json"
	}).done(function( data ) {
		differentTypes = data;
		load_it();
	});

	$("button").click(function() {
		var theType = this.id;

		if (theType == "newNameSave") {
			$.post("makenew", {
	        	name: $("#new_name").val(),
	        	hl: $("#new_hl").val()
		    }).done(function( data ) {
		    	if (data == "success") {
		    		window.location.href = window.location.href;
		    	}
		    	else {
		    		alert("an error occured");
		    	}
	  		});
			return;
		}

		$.post("did", {
	        type: theType,
	        amt: $("#"+theType+"_amt").val()
	    }).done(function( data ) {
	    	var Namt = parseInt($("#"+theType+"_current").html());
	    	$("#"+theType+"_current").html(Namt + parseInt($("#"+theType+"_amt").val()));
   			$("#"+theType+"_amt").val("");
  		});
	});

});
