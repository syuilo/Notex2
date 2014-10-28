part of notex2;

class Strike extends Element {
	String name = 'strike';
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return "<del>$html</del>";
	}
	
	static bool check(Scanner scanner, Token token) {
        	return
        		(token.token == 'tilde') &&
        		(scanner.pick(token.id + 1).token == 'tilde');
        }

	static Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
		if (filter != null) {
			if (filter.indexOf('strike') > -1) {
				return null;
        		}
        	}
        	return generate(parser, parent, inspecter, filter);
        }
	
	static Strike generate(Parser parser, Element parent, [inspecter(token), List<String> filter]) {
		Token startToken = parser.scanner.read();
		Strike strike = new Strike();
		strike.parent = parent;
		parser.scanner.next(2);
		if (filter == null) {
			filter = ['paragraph'];
		} else {
			filter.add('paragraph');
		}
		strike.children = parser.analyze(strike, (token) {
			return (token.token == 'tilde' && parser.scanner.tokens[token.id + 1].token == 'tilde');
		}, filter, () {
			parser.addError(new Error(
				'${startToken.row}行目の${startToken.col}列目あたりから始まった Strike(~~) が閉じていません。',
				startToken.row,
				startToken.col
				));
		});
		parser.scanner.next();
		return strike;
	}
}

