part of Notex2;

/**
 * Paragraph
 */
class Paragraph extends Element {
	String name = 'paragraph';
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		html = html.trim();
		//html = html.replaceAll(new RegExp(r'\n{2, 0}'), '\n');
		html = html.replaceAll('\n', '</br>');
		if (html != '') {
			return indent(hierarchy) + "<p>$html</p>\n";
		} else {
			return '';
		}
	}
	
	static Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
        	if (filter != null) {
        		if (filter.indexOf('paragraph') > -1) {
        			return null;
        		}
        	}
        	return generate(parser, parent, inspecter);
        }
	
	static Paragraph generate(Parser parser, Element parent, [inspecter(token)]) {
		Paragraph p = new Paragraph();
		p.parent = parent;
		p.children = parser.analyze(p, (token) {
			if (Section.check(parser.scanner, token)) {
				return true;
			} else if (EList.check(parser.scanner, token)) {
				return true;
			} else if (Blockquote.check(parser.scanner, token)) {
				return true;
			} else if (MultiLineCode.check(parser.scanner, token)) {
				return true;
			} else if (Table.check(parser.scanner, token)) {
				return true;
			} else {
				// ?
				if (inspecter != null) {
        				if (inspecter(token)) {
        					return true;
        				}
        			}
				
				if (token.token == 'newline' && parser.scanner.read(1).token == 'newline') {
					parser.scanner.next();
					return true;
				}
				return false;
			}
		});
		return p;
	}
}

