part of notex2;

class Image extends Element {
	String name = 'image';
	String url = "";
	
	String toHtml([String id = '', int hierarchy = 0]) {
		return "<img src=\"$url\" alt=\"image\"/>";
	}
	
	static bool check(Scanner scanner, Token token) {
        	return
        		(token.token == 'exclamation_mark') &&
        		(scanner.pick(token.id + 1).token == 'open_bracket');
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
		Token startToken = parser.scanner.read();
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
		}, () {
			parser.addError(new Error(
				'${startToken.row}行目の${startToken.col}列目あたりから始まった Image(!) が閉じていません。',
				startToken.row,
				startToken.col
				));
		});
		img.url = htmlEscape(img.url);
		return img;
	}
}
