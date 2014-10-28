part of notex2;

class MultiLineCode extends Element {
	String name = 'multilinecode';
	String code = "";
	String lang = "plain";
	
	String toHtml([String id = '', int hierarchy = 0]) {
		return indent(hierarchy) + "<pre><code data-lang=\"$lang\">$code</code></pre>\n";
	}
	
	static bool check(Scanner scanner, Token token) {
        	return
        		(token.token == 'newline') &&
        		(scanner.pick(token.id + 1).token == 'quotation') &&
        		(scanner.pick(token.id + 2).token == 'quotation') &&
        		(scanner.pick(token.id + 3).token == 'quotation');
        }

	static  Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
        	if (filter != null) {
        		if (filter.indexOf('multilinecode') > -1) {
        			return null;
        		}
        	}
        	return generate(parser, parent);
        }
	
	static MultiLineCode generate(Parser parser, Element parent) {
			Token startToken = parser.scanner.read();
        		MultiLineCode code = new MultiLineCode();
        		code.parent = parent;
        		parser.scanner.next(4);
        		if (parser.scanner.read().token == 'at_mark') {
        			parser.scanner.next();
        			code.lang = "";
        			parser.scanner.scan((Token token) {
        	    			switch (token.token) {
        	    				case 'newline':
        	    					parser.scanner.next();
        	    					return true;
        	    				default:
        	    					code.lang += token.lexeme;
        	    					break;
        	    			}
        	    			parser.scanner.next();
        	    		});
        		}
        		parser.scanner.scan((Token token) {
        			switch (token.token) {
        				case 'escape':
        					parser.scanner.next();
                                		code.code += parser.scanner.read().lexeme;
        					break;
        				case 'quotation':
        					if (parser.scanner.read(1).token == 'quotation' &&
        						parser.scanner.read(2).token == 'quotation') {
        						parser.scanner.next(3);
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
        				'${startToken.row}行目の${startToken.col}列目あたりから始まった Code(\'\'\') が閉じていません。',
        				startToken.row,
        				startToken.col
        				));
        		});
        		code.code = htmlEscape(code.code.trim());
        		code.lang = htmlEscape(code.lang);
        		return code;
        	}
}
