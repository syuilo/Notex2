part of Notex2;

class Table extends Element {
	String name = 'table';
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml(id, hierarchy + 1);
		}
		return indent(hierarchy) + "<table>\n$html" + indent(hierarchy) + "</table>\n";
	}
	
	static bool check(Scanner scanner, Token token) {
        	return
        		token.token == 'newline' &&
        		scanner.pick(token.id + 1).token == 'vertical_bar';
        }
	
	static  Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
        	if (filter != null) {
        		if (filter.indexOf('table') > -1) {
        			return null;
        		}
        	}
        	return generate(parser, parent);
        }
	
	static Table generate(Parser parser, Element parent) {
		var x = parser.scanner.read();
		Table table = new Table();
		table.parent = parent;
		parser.scanner.next(2);
		parser.scanner.scan((Token token) {
			if (token.token == 'newline' && parser.scanner.pick(token.id + 1).token != 'vertical_bar') {
				return true;
			}
			TableRow tr = new TableRow();
			tr.parent = table;
			parser.scanner.scan((Token token) {
				if (token.token == 'newline') {
					return true;
				}
				if (parser.scanner.read().token == 'vertical_bar') {
					parser.scanner.next();
					TableHeader th = new TableHeader();
					th.parent = tr;
					th.children = parser.analyze(th, (token) {
						return token.token == 'vertical_bar' || token.token == 'newline';
                			}, ['paragraph']);
					tr.children.add(th);
					parser.scanner.next();
					if (parser.scanner.read(-1).token == 'newline' && parser.scanner.read().token != 'vertical_bar') {
						parser.scanner.back(2);
        					return true;
        				}
					if (parser.scanner.read(-1).token == 'newline') {
        					return true;
        				}
				} else {
					TableData td = new TableData();
					td.parent = tr;
					td.children = parser.analyze(td, (token) {
						return token.token == 'vertical_bar' || token.token == 'newline';
                			}, ['paragraph']);
					tr.children.add(td);
					parser.scanner.next();
					if (parser.scanner.read(-1).token == 'newline' && parser.scanner.read().token != 'vertical_bar') {
						parser.scanner.back(2);
        					return true;
        				}
					if (parser.scanner.read(-1).token == 'newline') {
        					return true;
        				}
				}
			});
			table.children.add(tr);
			parser.scanner.next();
		});
		return table;
	}
}