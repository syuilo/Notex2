part of Notex2;

class Blockquote extends Element {
	String name = 'blockquote';
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml(id, hierarchy + 1);
		}
		return indent(hierarchy) + "<blockquote>\n$html" + indent(hierarchy) + "</blockquote>\n";
	}
	
	static bool check(List<Token> tokens, Token token) {
        	return (token.token == 'newline') && (tokens[token.id + 1].token == 'newline') && (tokens[token.id + 2].token == 'less_than');
        }

       static Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
        	if (filter != null) {
        		if (filter.indexOf('blockquote') > -1) {
        			return null;
        		}
        	}
        	return generate(parser, parent);
        }
       
	static Blockquote generate(Parser parser, Element parent, [inspecter(token), List<String> filter]) {
		Blockquote blockquote = new Blockquote();
		blockquote.parent = parent;
		parser.scanner.next(3);
		blockquote.children = parser.analyze(blockquote, (token) {
			if (token.token == 'newline' && parser.scanner.tokens[token.id + 1].token == 'newline') {
				return true;
			}
			return false;
		}, filter);
		return blockquote;
	}
}
