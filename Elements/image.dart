part of Notex2;

class Image extends Element {
	String name = 'image';
	String url = "";
	
	String toHtml([String id = '', int hierarchy = 0]) {
		return "<img src=\"$url\" alt=\"image\"/>";
	}
	
	static bool check(List<Token> tokens, Token token) {
        	return (token.token == 'exclamation_mark') && (tokens[token.id + 1].token == 'open_bracket');
        }

	static Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
        	if (filter != null) {
        		if (filter.indexOf('image') > -1) {
        			return null;
        		}
        	}
        	return generate(parser, parent);
        }
	
	static Image generate(Parser parser, Element parent) {
		Image img = new Image();
		img.parent = parent;
		parser.scanner.next(2);
		parser.scanner.scan((Token token) {
			switch (token.token) {
				case 'close_bracket':
					return true;
				default:
					img.url += token.lexeme;
					break;
			}
			parser.scanner.next();
		});
		img.url = htmlEscape(img.url);
		return img;
	}
}
