part of Notex2;

class Keyword extends Element {
	String name = 'keyword';
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return "<b>$html</b>";
	}
	
	static bool check(Scanner scanner, Token token) {
        	return
        		(token.token == 'asterisk') &&
        		(scanner.pick(token.id + 1).token != 'asterisk');
        }

	static Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
        	if (filter != null) {
        		if (filter.indexOf('keyword') > -1) {
        			return null;
        		}
        	}
        	return generate(parser, parent, inspecter, filter);
        }
	
	static Keyword generate(Parser parser, Element parent, [inspecter(token), List<String> filter]) {
		Keyword keyword = new Keyword();
		keyword.parent = parent;
		parser.scanner.next();
		if (filter == null) {
			filter = ['paragraph'];
		} else {
			filter.add('paragraph');
		}
		keyword.children = parser.analyze(keyword, (token) {
			return (token.token == 'asterisk') && (parser.scanner.tokens[token.id + 1].token != 'asterisk');
		}, filter);
		return keyword;
	}
}

