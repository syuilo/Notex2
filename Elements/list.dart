part of Notex2;

class EList extends Element {
	String name = 'list';
	String type = "unordered"; // unordered or ordered
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml(id, hierarchy + 1);
		}
		if (this.type == "ordered") {
			return indent(hierarchy) + "<ol>\n$html" + indent(hierarchy) + "</ol>\n";
		} else {
			return indent(hierarchy) + "<ul>\n$html" + indent(hierarchy) + "</ul>\n";
		}
	}
	
	static bool check(List<Token> tokens, Token token) {
        	return (token.token == 'newline') && ((tokens[token.id + 1].token == 'hyphen') || ((tokens[token.id + 1].token == 'number') && (tokens[token.id + 2].token == 'period')));
        }

        static Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
        	if (filter != null) {
        		if (filter.indexOf('list') > -1) {
        			return null;
        		}
        	}
        	return generate(parser, parent);
        }
        
       static EList generate(Parser parser, Element parent) {
		EList list = new EList();
		list.parent = parent;
		list.type = parser.scanner.read(1).token == 'number' ? 'ordered' : 'unordered';
		parser.scanner.next();
		parser.scanner.scan((Token token) {
			if (list.type == 'ordered') {
				parser.scanner.next(2);
			} else {
				parser.scanner.next();
			}
			EListItem item = new EListItem();
			item.children = parser.analyze(list, (token) {
				return token.token == 'newline';
			}, ['paragraph']);
			list.children.add(item);
			if (parser.scanner.read(1).token == 'newline') {
				parser.scanner.next();
				return true;
			}
			parser.scanner.next();
		});
		return list;
	}
}
