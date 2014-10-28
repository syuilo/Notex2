part of notex2;

/**
 * TextはElement木の葉ノードです。
 */
class Text extends Element {
	String name = 'text';
	String text = "";
	
	bool childFind(String name) {
		return false;
	}
	
	bool childSearch(String name) {
		if (name == this.name) {
			return true;
		} else {
			return false;
		}
	}
	
	String toHtml([String id = '', int hierarchy = 0]) {
		return htmlEscape(this.text);
	}
	
	static Text generate(Parser parser, Element parent, [inspecter(token), List<String> filter]) {
		Text text = new Text();
		text.parent = parent;
		parser.scanner.scan((Token token) {
			if (inspecter != null) {
				if (inspecter(token)) {
					return true;
				}
			}
			if (Blockquote.check(parser.scanner, token)) {
				return true;
			} else if (MultiLineCode.check(parser.scanner, token)) {
				return true;
			} else if (Image.check(parser.scanner, token)) {
				return true;
			} else if (Link.check(parser.scanner, token)) {
				return true;
			} else if (EList.check(parser.scanner, token)) {
				return true;
			} else if (Section.check(parser.scanner, token)) {
				return true;
			} else if (Strike.check(parser.scanner, token)) {
				return true;
			} else if (Strong.check(parser.scanner, token)) {
				return true;
			} else {
				text.text = token.lexeme;
				 return true;
			}
			parser.scanner.next();
		});
		return text;
	}
}