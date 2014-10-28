part of notex2;

class Strong extends Element {
	String name = 'strong';
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return "<strong>$html</strong>";
	}
	
	static bool check(Scanner scanner, Token token) {
        	return
        		(token.token == 'asterisk') &&
        		(scanner.pick(token.id + 1).token == 'asterisk');
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
		Token startToken = parser.scanner.read();
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
		}, filter, () {
			parser.addError(new Error(
				'${startToken.row}行目の${startToken.col}列目あたりから始まった Strong(**) が閉じていません。',
				startToken.row,
				startToken.col
				));
		});
		parser.scanner.next();
		return strong;
	}
}

