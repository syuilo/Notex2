part of Notex2;

class Link extends Element {
	String name = 'link';
	String url = "";
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return "<a href=\"$url\" target=\"_blank\">$html</a>";
	}
	
	static bool check(Scanner scanner, Token token) {
        	return (token.token == 'open_square_bracket');
        }

        static Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
        	if (filter != null) {
        		if (filter.indexOf('link') > -1) {
        			return null;
        		}
        	}
        	return generate(parser, parent, inspecter, filter);
        }
        
       static Link generate(Parser parser, Element parent, [inspecter(token), List<String> filter]) {
		Link link = new Link();
		link.parent = parent;
		parser.scanner.next();
		parser.scanner.scan((Token token) {
			link.children = parser.analyze(link, (token) {
				return token.token == 'close_square_bracket';
			}, filter);
			return true;
		});
		parser.scanner.next(2);
		parser.scanner.scan((Token token) {
			switch (token.token) {
				case 'close_bracket':
					return true;
				default:
					link.url += token.lexeme;
					break;
			}
			parser.scanner.next();
		});
		link.url = htmlEscape(link.url);
		return link;
	}
}

