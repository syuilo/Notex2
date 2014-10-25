part of Notex2;

class Strong extends Element {
	String name = 'strong';
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return "<strong>$html</strong>";
	}
	
	static bool check(List<Token> tokens, Token token) {
        	return (token.token == 'asterisk') && (tokens[token.id + 1].token == 'asterisk');
        }

	static Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
        	if (filter != null) {
        		if (filter.indexOf('strong') > -1) {
        			return null;
        		}
        	}
        	return generate(parser, parent, inspecter, filter);
        }
	
	static Strong generate(Parser parser, Element parent, [inspecter(token), List<String> filter]) {
		Strong strong = new Strong();
		strong.parent = parent;
		parser.scanner.next(2);
		if (filter == null) {
			filter = ['paragraph'];
		} else {
			filter.add('paragraph');
		}
		strong.children = parser.analyze(strong, (token) {
			return (token.token == 'asterisk') && (parser.scanner.tokens[token.id + 1].token == 'asterisk');
		}, filter);
		parser.scanner.next();
		return strong;
	}
}

