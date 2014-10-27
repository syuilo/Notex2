import "Notex2/notex2.dart";
import 'dart:html';

void main() {
	
	TextAreaElement input = querySelector("#source");
	var compile = () {
		String source = input.value;
		var note = new Notex2(source);
		
		Article a = note.compile();
		String html = a.toHtml();
		String tableOfContents = a.genelateTableOfContentsHtml('');
		querySelector("#output").text = html;
		querySelector("#article_main").setInnerHtml(html == null ? '' : html,
                                validator: new NodeValidatorBuilder()
                                ..allowHtml5()
                                ..allowElement('a', attributes: ['href'])
                                ..allowElement('img', attributes: ['src'])
                                ..allowElement('code', attributes: ['data-lang'])
                                );
		querySelector("#tableOfContents").setInnerHtml(tableOfContents == null ? '' : tableOfContents,
                                validator: new NodeValidatorBuilder()
                                ..allowHtml5()
                                ..allowElement('a', attributes: ['href'])
                                );
		
		String errorHtml = '<ol>';
		for (var error in note.parser.errors) {
			errorHtml += '<li>${error.description}</li>';
		}
		errorHtml += '</ol>';
		querySelector("#error").setInnerHtml(errorHtml);
	};
	compile();
	input.onInput.listen((e)=>compile());
 
		/*
	var compile = ([String source]) {
		if (source == null) {
			source = querySelector("#source").text;
		}
		var note = new Notex2(source);
		
		Article a = note.compile();
		String html = a.toHtml('article');
		String tableOfContents = a.genelateTableOfContentsHtml('article');
		querySelector("#article-main").setInnerHtml(html == null ? '' : html,
	                        validator: new NodeValidatorBuilder()
	                        ..allowHtml5()
	                        ..allowElement('a', attributes: ['href'])
	                        ..allowElement('img', attributes: ['src'])
	                        ..allowElement('code', attributes: ['data-lang'])
	                        );
		querySelector("#tableOfContents").setInnerHtml(tableOfContents == null ? '' : tableOfContents,
	                        validator: new NodeValidatorBuilder()
	                        ..allowHtml5()
	                        ..allowElement('a', attributes: ['href'])
	                        );
	};
	compile();
	TextAreaElement input = querySelector("#editarea");
	input.value = querySelector("#source").text;
	input.onInput.listen((e)=>compile(input.value));
            */  
}
