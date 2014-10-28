part of notex2;

class Code extends Element {
	String name = 'code';
	String code = "";
	String lang = "plain";
	
	String toHtml([String id = '', int hierarchy = 0]) {
		return "<code data-lang=\"$lang\">$code</code>";
	}
	
	static bool check(Scanner scanner, Token token) {
        	return
        		(token.token == 'quotation') &&
        		(scanner.pick(token.id + 1).token == 'quotation') &&
        		(scanner.pick(token.id + 2).token != 'quotation');
        }

	static  Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
        	if (filter != null) {
        		if (filter.indexOf('code') > -1) {
        			return null;
        		}
        	}
        	return generate(parser, parent);
        }
	
	static Code generate(Parser parser, Element parent) {
		Token startToken = parser.scanner.read();
		Code code = new Code();
		code.parent = parent;
		parser.scanner.next(2);
		parser.scanner.scan((Token token) {
			switch (token.token) {
				case 'escape':
					parser.scanner.next();
                        		code.code += parser.scanner.read().lexeme;
					break;
				case 'quotation':
					if (parser.scanner.read(1).token == 'quotation' &&
						parser.scanner.read(2).token != 'quotation') {
						parser.scanner.next(1);
						return true;
					}
					continue text;
			text:
				default:
					code.code += token.lexeme;
					break;
			}
			parser.scanner.next();
		}, () {
			parser.addError(new Error(
				'${startToken.row}行目の${startToken.col}列目あたりから始まった Code(\'\') が閉じていません。',
				startToken.row,
				startToken.col
				));
		});
		code.code = htmlEscape(code.code.trim());
		code.lang = htmlEscape(code.lang);
		return code;
	}
}
