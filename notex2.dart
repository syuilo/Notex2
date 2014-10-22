/*
 * Copyright (c) 2014 syuilo All rights reserved.
 * Thanks for Akari, Chinatsu, Yui, Kyoko and you.
 *                                                      syuilo
 **************************************************************** */

library Notex2;

void scream() {
	print("うー！にゃー！" * 4);
}

String indent(int hierarchy) {
	//return ("\t" * hierarchy);
	return ("    " * hierarchy);
}

/**
 * Token
 */
class Token {
	String token = "";
	String lexeme = "";
}

abstract class Element {
	/**
	 * HTML文字列を生成します。
	 */
	String toHtml([int hierarchy = 0]);
	
	/**
	 * 自分の親にParagraphが存在するかどうかを取得します。
	 */
	bool findParagraph();
}

class Text extends Element {
	String text = "";
	Element parent;
	
	bool findParagraph() {
		return this.parent.findParagraph();
	}
	
	String toHtml([int hierarchy = 0]) {
		String html = this.text;
		html = html.replaceAll(new RegExp(r'\n\n'), '\n');
		html = html.replaceAll(new RegExp(r'^\n'), '');
		html = html.replaceAll(new RegExp(r'\n$'), '');
		html = html.replaceAll('\n', '</br>');
		return html;
	}
}

class Article extends Element {
	List<Element> children;
	
	bool findParagraph() {
		return false;
	}
	
	Article() {
		this.children = new List();
	}
	
	String toHtml([int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml(hierarchy + 1);
		}
		return "<article>\n$html</article>";
	}
}
/*
class Div extends Element {
	List<Element> children;
}
*/
class Section extends Element {
	int hierarchy;
	String title = "";
	Element parent;
	List<Element> children;
	
	Section() {
		this.children = new List();
	}
	
	bool findParagraph() {
		return this.parent.findParagraph();
	}
	
	String toHtml([int hierarchy = 0]) {
		String html = "";
		String h = "h$hierarchy";
		for (Element element in this.children) {
			html += element.toHtml(hierarchy + 1);
		}
		return indent(hierarchy) + "<section>\n"
				+ indent(hierarchy + 1) + "<$h>$title</$h>\n"
				+ html
				+ indent(hierarchy) + "</section>\n";
	}
}

class Paragraph extends Element {
	Element parent;
	List<Element> children;
	
	Paragraph() {
		this.children = new List();
	}
	
	bool findParagraph() {
		return true;
	}
	
	String toHtml([int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return indent(hierarchy) + "<p>$html</p>\n";
	}
}

class Strong extends Element {
	Element parent;
	List<Element> children;
	
	Strong() {
		this.children = new List();
	}
	
	bool findParagraph() {
		return this.parent.findParagraph();
	}
	
	String toHtml([int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return "<strong>$html</strong>";
	}
}

class Link extends Element {
	String url = "";
	Element parent;
	List<Element> children;
	
	Link() {
		this.children = new List();
	}
	
	bool findParagraph() {
		return this.parent.findParagraph();
	}
	
	String toHtml([int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return "<a href=\"$url\" target=\"_blank\">$html</a>";
	}
}

class Image extends Element {
	String url = "";
	Element parent;
	
	Image() {
	}
	
	bool findParagraph() {
		return this.parent.findParagraph();
	}
	
	String toHtml([int hierarchy = 0]) {
		return "<img src=\"$url\" alt=\"image\"/>";
	}
}

class Code extends Element {
	String code = "";
	String lang = "plain";
	Element parent;
	
	Code() {
	}
	
	bool findParagraph() {
		return this.parent.findParagraph();
	}
	
	String toHtml([int hierarchy = 0]) {
		return indent(hierarchy) + "<pre><code data-lang=\"$lang\">$code</code></pre>\n";
	}
}

class EList extends Element {
	String type = "unordered"; // unordered or ordered
	Element parent;
	List<EListItem> children;
	
	EList() {
		this.children = new List();
	}
	
	bool findParagraph() {
		return this.parent.findParagraph();
	}
	
	String toHtml([int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml(hierarchy + 1);
		}
		if (this.type == "ordered") {
			return indent(hierarchy) + "<ol>\n$html" + indent(hierarchy) + "</ol>\n";
		} else {
			return indent(hierarchy) + "<ul>\n$html" + indent(hierarchy) + "</ul>\n";
		}
	}
}

class EListItem extends Element {
	EList parent;
	List<Element> children;
	
	EListItem() {
		this.children = new List();
	}
	
	bool findParagraph() {
		return this.parent.findParagraph();
	}
	
	String toHtml([int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return indent(hierarchy) + "<li>$html</li>\n";
	}
}

/**
 * コンパイラ本体です。
 */
class Notex2 {
	String source;
	List<Token> tokens;
	int pos = 0; // トークンリーダの位置
	int hierarchy = 0; // 現在の階層
	String tableOfContents = "";
	int sectionCount = 0;
	
	Notex2(String source) {
		this.source = source;
		this.tokens = new List();
	}
	
	Article compile() {
		this.tokens = this.lexicalAnalyzer();
		Article article = new Article();
		article.children = this.analyze(article, (token){return false;});
		return article;
	}
	
	/**
	 * 字句解析器。トークンリストを生成します。
	 */
	List<Token> lexicalAnalyzer() {
		List<Token> tokens = new List();
		int pos = 0;
		Token tokeniza() {
			Token token = new Token();
			bool text = false;
			while ((pos + 1) != this.source.length) {
				String char = this.source[pos];
				pos++;
				switch (char) {
					case ' ':
						if (!text) {
							token.token = 'space';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '\n':
						if (!text) {
							token.token = 'newline';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '0':
					case '1':
					case '2':
					case '3':
					case '4':
					case '5':
					case '6':
					case '7':
					case '8':
					case '9':
						if (!text) {
							token.token = 'number';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '\'':
						if (!text) {
							token.token = 'quotation';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
						
					case '\"':
						if (!text) {
							token.token = 'double_quotation';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '.':
						if (!text) {
							token.token = 'period';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '@':
						if (!text) {
							token.token = 'at_mark';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '#':
						if (!text) {
							token.token = 'sharp';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '*':
						if (!text) {
							token.token = 'asterisk';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '-':
						if (!text) {
							token.token = 'hyphen';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '(':
						if (!text) {
							token.token = 'open_bracket';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case ')':
						if (!text) {
							token.token = 'close_bracket';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '[':
						if (!text) {
							token.token = 'open_square_bracket';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case ']':
						if (!text) {
							token.token = 'close_square_bracket';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '<':
						if (!text) {
							token.token = 'greater_than';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '>':
						if (!text) {
							token.token = 'less_than';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					case '!':
						if (!text) {
							token.token = 'exclamation_mark';
							token.lexeme = char;
						} else {
							pos--;
						}
						return token;
					default:
						text = true;
						token.token = 'text';
						token.lexeme += char;
						break;
				}
				
			}
			return token;
		}
		
		while ((pos + 1) != this.source.length) {
			var token = tokeniza();
			print("${token.token}\t: ${token.lexeme}");
			tokens.add(token);
		}
		
		return tokens;
	}
	
	Element verifySection(Element parent, [inspecter(Token token), List<String> filter]) {
		if (filter != null) {
			if (filter.indexOf('section') > -1) {
				return null;
			}
		}
		return this.analyzeSection(parent);
	}
	
	Element verifyParagraph(Element parent, [inspecter(Token token), List<String> filter]) {
		if (filter != null) {
			if (filter.indexOf('paragraph') > -1) {
				return null;
			}
		}
		return this.analyzeParagraph(parent);
	}
	
	Element verifyStrong(Element parent, [inspecter(Token token), List<String> filter]) {
		if (filter != null) {
			if (filter.indexOf('strong') > -1) {
				return null;
			}
		}
		return this.analyzeStrong(parent);
	}
	
	Element verifyLink(Element parent, [inspecter(Token token), List<String> filter]) {
		if (filter != null) {
			if (filter.indexOf('link') > -1) {
				return null;
			}
		}
		return this.analyzeLink(parent, inspecter, filter);
	}
	
	Element verifyImage(Element parent, [inspecter(Token token), List<String> filter]) {
		if (filter != null) {
			if (filter.indexOf('image') > -1) {
				return null;
			}
		}
		return this.analyzeImage(parent);
	}
	
	Element verifyList(Element parent, [inspecter(Token token), List<String> filter]) {
		if (filter != null) {
			if (filter.indexOf('list') > -1) {
				return null;
			}
		}
		return this.analyzeList(parent);
	}
	
	Element verifyCode(Element parent, [inspecter(Token token), List<String> filter]) {
		if (filter != null) {
			if (filter.indexOf('code') > -1) {
				return null;
			}
		}
		return this.analyzeCode(parent);
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
	List<Element> analyze(Element parent, [inspecter(Token token), List<String> filter]) {
		List<Element> elements = new List();
		this.scan((Token token) {
			if (inspecter != null) {
				if (inspecter(token)) {
					return true;
				}
			}
			switch (token.token) {
				case 'sharp': // Section
					Element element = verifySection(parent, inspecter, filter);
					if (element != null) elements.add(element); else continue text;
					break;
				case 'asterisk': // Strong
					Element element = verifyStrong(parent, inspecter, filter);
					if (element != null) elements.add(element); else continue text;
					break;
				case 'open_square_bracket': // Link
					Element element = verifyLink(parent, inspecter, filter);
					if (element != null) elements.add(element); else continue text;
					break;
				case 'exclamation_mark': // Image
					Element element = verifyImage(parent, inspecter, filter);
					if (element != null) elements.add(element); else continue text;
					break;
				case 'newline':
					if (this.read(1).token == 'hyphen' ||
						this.read(1).token == 'number') { // List
						Element element = verifyList(parent, inspecter, filter);
    					if (element != null) elements.add(element); else continue text;
						break;
					}
					continue text;
				case 'quotation':
					if (this.read(1).token == 'quotation' &&
						this.read(2).token == 'quotation') { // Code
						Element element = verifyCode(parent, inspecter, filter);
    					if (element != null) elements.add(element); else continue text;
						elements.add(this.analyzeCode(parent));
						break;
					}
					continue text;
			text:
				default:
					if (!parent.findParagraph()) {
						Element element = verifyParagraph(parent, inspecter, filter);
    					if (element != null) {
    						elements.add(element);
    					} else {
    						elements.add(this.analyzeText(parent, inspecter, filter));
    					}
					} else {
						elements.add(this.analyzeText(parent, inspecter, filter));
					}
					if (inspecter != null) {
        				if (inspecter(this.read())) {
        					return true;
        				}
        			}
					break;
			}
		});
		return elements;
	}
	
	/**
	 * テキストを解析します。テキストは子要素を持つことはなく、最小の単位です。
	 */
	Text analyzeText(Element parent, [inspecter(token), List<String> filter]) {
		Text text = new Text();
		text.parent = parent;
		//this.back();
		this.scan((Token token) {
			if (inspecter != null) {
				if (inspecter(token)) {
					return true;
				}
			}
			switch (token.token) {
				case 'asterisk':
					if (filter != null) {
            			if (filter.indexOf('strong') > -1) {
            				continue text;
            			}
            		}
					this.back();
					return true;
				case 'open_square_bracket':
					this.back();
					return true;
				case 'exclamation_mark':
					this.back();
					return true;
				case 'sharp':
					this.back();
					return true;
				case 'newline':
					if (this.read(1).token == 'hyphen' ||
						this.read(1).token == 'number') { // List
						return true;
					}
					continue text;
				case 'quotation':
					if (this.read(1).token == 'quotation' &&
						this.read(2).token == 'quotation') { // Code
    					return true;
					}
					continue text;
			text:
				default:
					text.text = token.lexeme;
					return true;
			}
		});
		return text;
	}
	
	/**
	 * Paragraphを解析します。
	 */
	Element analyzeParagraph(Element parent, [inspecter(token)]) {
		Paragraph p = new Paragraph();
		p.parent = parent;
		this.scan((Token token) {
			if (inspecter != null) {
				if (inspecter(token)) {
					return true;
				}
			}
			switch (token.token) {
				case 'sharp':
					this.back();
					return true;
				case 'asterisk':
					p.children.add(this.analyzeStrong(p));
					break;
				case 'open_square_bracket':
					p.children.add(this.analyzeLink(p));
					break;
				case 'exclamation_mark':
					p.children.add(this.analyzeImage(p));
					break;
				case 'newline':
					if (this.read(1).token == 'hyphen' ||
						this.read(1).token == 'number') { // List
						this.back();
						return true;
					}
					continue text;
				case 'quotation':
					if (this.read(1).token == 'quotation' &&
						this.read(2).token == 'quotation') { // Code
						this.back();
						return true;
					}
					continue text;
			text:
				default:
					p.children.add(this.analyzeText(p, inspecter));
					if (inspecter != null) {
        				if (inspecter(this.tokens[this.pos])) {
        					return true;
        				}
        			}
					break;
			}
		});
		return p;
	}
	
	/**
	 * セクションを解析します。
	 */
	Section analyzeSection(Element parent) {
		Section section = new Section();
		section.parent = parent;
		section.hierarchy = 0;
		bool secEnd = false;
		
		this.scan((Token token) {
			if (!secEnd) {
				switch (token.token) {
					case 'sharp':
						if (section.title == "") {
							section.hierarchy++;
						} else {
							secEnd = true;
						}
						break;
					case "newline":
						print("["+("-"*(section.hierarchy-1))+"> セクションの開始 h:${section.hierarchy} title:${section.title}]");
						secEnd = true;
						break;
					default:
						section.title += token.lexeme;
						break;
				}
			} else {
				section.children = this.analyze(section, (token) {
					if (token.token == 'sharp') {
						// 次に始まるセクションの階層を調べる
						// もし自分より上か同階層なら自分のセクションは終了
						
						int nextSectionHierarchy = 1;
						int step = 0;
						this.next();
						this.scan((Token secToken) {
							step++;
							if (secToken.token == 'sharp') {
								nextSectionHierarchy++;
								return false;
							} else {
								return true;
							}
						});
						// 階層を調べるために進めたトークンリーダを元の位置まで巻き戻す
						this.back(step);
						if (nextSectionHierarchy <= section.hierarchy) {
							this.back();
							return true;
						} else {
							return false;
						}
					} else {
						return false;
					}
				});
				return true;
			}
		});
		print("["+("-"*(section.hierarchy-1))+"< セクションの終了 h:${section.hierarchy} title:${section.title}]");
		return section;	
	}
	
	/**
	 * Strongを解析します。
	 */
	Strong analyzeStrong(Element parent) {
		Strong strong = new Strong();
		strong.parent = parent;
		this.next();
		this.scan((Token token) {
			switch (token.token) {
				case 'asterisk':
					this.next();
					return true;
				default:
					strong.children.add(this.analyzeText(strong));
					this.next();
					return true;
			}
		});
		return strong;
	}
	
	/**
	 * リンクを解析します。
	 */
	Link analyzeLink(Element parent, [inspecter(token), List<String> filter]) {
		Link link = new Link();
		link.parent = parent;
		this.next();
		this.scan((Token token) {
			link.children = this.analyze(link, (token) {
				return token.token == 'close_square_bracket';
			}, filter);
			return true;
		});
		// URLが見つかるまで空回し
		this.scan((Token token){return token.token == 'open_bracket';});
		this.next();
		this.scan((Token token) {
			switch (token.token) {
				case 'close_bracket':
					return true;
				default:
					link.url += token.lexeme;
					break;
			}
		});
		return link;
	}
	
	Image analyzeImage(Element parent) {
		Image img = new Image();
		img.parent = parent;
		this.next();
		this.scan((Token token) {
			switch (token.token) {
				case 'close_bracket':
					return true;
				default:
					img.url += token.lexeme;
					break;
			}
		});
		return img;
	}
	
	Code analyzeCode(Element parent) {
		scream();
		Code code = new Code();
		code.parent = parent;
		this.next(3);
		if (this.read().token == 'at_mark') {
			this.next();
			code.lang = "";
			this.scan((Token token) {
    			switch (token.token) {
    				case 'newline':
    					this.next();
    					return true;
    				default:
    					code.lang += token.lexeme;
    					break;
    			}
    		});
		}
		this.scan((Token token) {
			switch (token.token) {
				case 'quotation':
					if (this.read(1).token == 'quotation' &&
						this.read(2).token == 'quotation') {
						this.next(3);
						return true;
					}
					continue text;
			text:
				default:
					code.code += token.lexeme;
					break;
			}
		});
		return code;
	}
	
	EList analyzeList(Element parent) {
		EList list = new EList();
		list.parent = parent;
		list.type = this.read(1).token == 'number' ? 'ordered' : 'unordered';
		this.next();
		this.scan((Token token) {
			if (list.type == 'ordered') {
				this.next(2);
			} else {
				this.next();
			}
			EListItem item = new EListItem();
			item.children = this.analyze(list, (token) {
				return token.token == 'newline';
			}, ['paragraph']);
			list.children.add(item);
			if (this.read(1).token == 'newline') {
				this.next();
				return true;
			}
		});
		return list;
	}
	
	/**
	 * トークンリーダを指定した分だけ進めます。
	 */
	void next([int step = 1]) {
		if ((this.pos + step) < this.tokens.length) {
			this.pos += step;
		} else {
			this.pos = this.tokens.length - 1;
		}
	}
	
	/**
	 * トークンリーダを指定した分だけ巻き戻します。
	 */
	void back([int step = 1]) {
		this.pos -= step;
	}
	
	/**
	 * 現在のトークンリーダの位置にあるトークンを読み出します。
	 */
	Token read([int relative_pos = 0]) {
		return this.tokens[this.pos + relative_pos];
	}
	
	/**
	 * ソースを走査します。トークンに出会う度に指定されたスキャナが呼ばれます。
	 * スキャナが [true] を返した場合、そこで直ちに走査は終了し、関数が終了します。
	 */
	void scan(bool scanner(Token token)) {
		while ((this.pos + 1) < this.tokens.length) {
			Token token = this.read();
			//print(token);
			if (scanner(token) == true) {
				break;
			}	
			this.next();
		}
	}
}
