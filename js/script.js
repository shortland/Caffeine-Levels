/*
* Ilan Kleiman
* script.js
* 10/22/17
*/

// !!! add supp for the added ones

$(document).ready(function() {

	var load_it = function() {
		$.ajax({
			method: "GET",
			url: "howmuch?type=all"
		}).done(function( data ) {
			var json = JSON.parse(data);
			$("#Caffeine_current").html( json.["Caffeine"] );
		});
		
		setTimeout(load_it, 2000);
	}
	load_it();

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
