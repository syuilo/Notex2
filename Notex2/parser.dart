part of Notex2;

class Error {
	String description = '';
	int row = 0;
	int col = 0;
	
	Error(String description, [int row = 0, int col = 0]) {
		this.description = description;
		this.row = row;
		this.col = col;
	}
}

/**
 * 構文解析器
 */
class Parser {
	Scanner scanner;
	int sectionCount = 0;
	List<Error> errors = new List();
	
	Parser(Scanner scanner) {
		this.scanner = scanner;
	}
	
	void addError(Error error) {
		this.errors.add(error);
	}
	
	/**
	 * トークンを解析し、要素を生成します。
	 * スキャンが開始される位置は現在のトークンリーダに基づきます。
	 * 
	 * @param Element parent 生成される要素の親になる要素。
	 * @param function(Token token) inspector 設定するとトークンの読み出しごとに読み出したトークンを与えて呼び出されます。[true]を返すとスキャンは直ちに終了します。
	 * @param List<String> filter 生成を禁止する要素の名称の配列。設定すると、ここに記載されている要素は生成対象にしません。
	 * 
	 * @return 生成された要素の配列。
	 */
	List<Element> analyze(Element parent, [inspecter(Token token), List<String> filter, void scanEnd()]) {
		List<Element> elements = new List();
		this.scanner.scan((Token token) {
			if (inspecter != null) {
				if (inspecter(token)) {
					return true;
				}
			}
			
			if (!parent.parentSearch('paragraph')) {
				Element element;
				if (Keyword.check(this.scanner, token) ||
					Strong.check(this.scanner, token) ||
					Strike.check(this.scanner, token) ||
					Link.check(this.scanner, token) ||
					Code.check(this.scanner, token)
				) {
					this.scanner.back();
					element = Paragraph.analyze(this, parent, inspecter, filter);
					
					if (element != null) {
        					elements.add(element);
						token = this.scanner.read();
        				} else {
        					this.scanner.next();
        				}
				}
			}

			switch (token.token) {
				case 'eof':
					return true;
				case 'escape':
					// 必殺技レキシカルトークンリライト (時空書き換え(危険))
					this.scanner.next();
					this.scanner.tokens[token.id + 1].token = 'text';
					break;
				default:
					Element element;
					if (Blockquote.check(this.scanner, token)) {
						element = Blockquote.analyze(this, parent, inspecter, filter);
					} else if (Code.check(this.scanner, token)) {
						element = Code.analyze(this, parent, inspecter, filter);
					} else if (MultiLineCode.check(this.scanner, token)) {
						element = MultiLineCode.analyze(this, parent, inspecter, filter);
					} else if (Image.check(this.scanner, token)) {
						element = Image.analyze(this, parent, inspecter, filter);
					} else if (Keyword.check(this.scanner, token)) {
                                        	element = Keyword.analyze(this, parent, inspecter, filter);
					} else if (Link.check(this.scanner, token)) {
						element = Link.analyze(this, parent, inspecter, filter);
					} else if (EList.check(this.scanner, token)) {
						element = EList.analyze(this, parent, inspecter, filter);
					} else if (Section.check(this.scanner, token)) {
						element = Section.analyze(this, parent, inspecter, filter);
					} else if (Strike.check(this.scanner, token)) {
						element = Strike.analyze(this, parent, inspecter, filter);
					} else if (Strong.check(this.scanner, token)) {
						element = Strong.analyze(this, parent, inspecter, filter);
					} else if (Table.check(this.scanner, token)) {
						element = Table.analyze(this, parent, inspecter, filter);
					} else {
						if (!parent.parentSearch('paragraph')) {
							Element element = Paragraph.analyze(this, parent, inspecter, filter);
        	    					if (element != null) {
        	    						elements.add(element);
        	    					} else {
        	    						elements.add(Text.generate(this, parent, inspecter, filter));
        	    						this.scanner.next();
        	    					}
        	    					break;
        					}
					}
					
					if (element != null) {
						elements.add(element);
					} else {
						elements.add(Text.generate(this, parent, inspecter, filter));
					}
					this.scanner.next();
					break;
			}
		}, scanEnd);
		return elements;
	}
}