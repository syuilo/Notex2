$(function() {
	$("#tableOfContents li").each(function() {
		if ($(this).children("ol")[0]) {
			$(this).attr("class", "section");
			$(this).children("a").html("<strong>"+$(this).children("a").html()+"</strong>");
			//$(this).children("ol").prepend("<li><a href=\""+$(this).children("a").attr("href")+"\">"+$(this).children("a").text()+"</a></li>");
			$(this).children("a").attr("href", "@");
			$(this).children("a").click(function(event) {
				event.preventDefault();
				if ($(this).attr("data-toggle") == "close") {
					$(this).closest("li").children("ol").show('blind', '', 500);
					$(this).attr("data-toggle", "open")
				} else {
					$(this).closest("li").children("ol").hide('blind', '', 500);
					$(this).attr("data-toggle", "close")
				}
			});
		}
	});
});