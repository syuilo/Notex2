/*
interface IElement {
	String toHtml();
}
*/

library Notex2;

String indent(int hierarchy) {
	return ("\t" * hierarchy);
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
		return this.text.replaceAll(new RegExp(r'\n\n'), '\n').replaceAll(new RegExp(r'\n'), '</br>');
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
		for (Element element in this.children) {
			html += element.toHtml(hierarchy + 1);
		}
		return indent(hierarchy)+"<section>\n"+indent(hierarchy+1)+"<h$hierarchy>$title</h$hierarchy>\n$html"+indent(hierarchy)+"</section>\n";
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
		return indent(hierarchy)+"<p>$html</p>\n";
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

class Notex2 {
	String source;
	int pos = 0; // トークンリーダの位置
	int hierarchy = 0; // 現在の階層
	String tableOfContents = "";
	int sectionCount = 0;
	
	bool is_strong = false;
	bool is_p = false;
	bool is_inlineClass = false;
	bool is_blockClass = false;
	
	Notex2(String source) {
		this.source = source;
	}
	
	Article compile() {
		Article article = new Article();
		article.children = this.analyze(article, (token){return false;});
		return article;
	}
	
	/**
	 * 
	 */
	List<Element> analyze(Element parent, [inspecter(token)]) {
		List<Element> elements = new List();
		this.scan((token) {
			if (inspecter != null) {
				if (inspecter(token)) {
					return true;
				}
			}
			switch (token) {
				case '#': // Section
					elements.add(this.analyzeSection(parent));
					break;
				case '*': // Strong
					elements.add(this.analyzeStrong(parent));
					break;
				case '[': // Link
					elements.add(this.analyzeLink(parent));
					break;
				case '!': // Image
					elements.add(this.analyzeImage(parent));
					break;
				default:
					if (!parent.findParagraph()) {
						elements.add(this.analyzeParagraph(parent, inspecter));
					} else {
						elements.add(this.analyzeText(parent, inspecter));
					}
					if (inspecter != null) {
                				if (inspecter(this.source[this.pos])) {
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
	Text analyzeText(Element parent, [inspecter(token)]) {
		Text text = new Text();
		text.parent = parent;
		//this.back();
		this.scan((token) {
			if (inspecter != null) {
				if (inspecter(token)) {
					return true;
				}
			}
			switch (token) {
				case '*':
					this.back();
					return true;
				case '[':
					this.back();
					return true;
				case '!':
					this.back();
					return true;
				case '#':
					this.back();
					return true;
				default:
					text.text += token;
					break;
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
		this.scan((token) {
			if (inspecter != null) {
				if (inspecter(token)) {
					return true;
				}
			}
			switch (token) {
				case '#':
					this.back();
					return true;
				case '*':
					p.children.add(this.analyzeStrong(p));
					break;
				case '[':
					p.children.add(this.analyzeLink(p));
					break;
				case '!':
					p.children.add(this.analyzeImage(p));
					break;
				default:
					p.children.add(this.analyzeText(p, inspecter));
					if (inspecter != null) {
                				if (inspecter(this.source[this.pos])) {
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
		
		this.scan((token) {
			if (!secEnd) {
				switch (token) {
					case '#':
						if (section.title == "") {
							section.hierarchy++;
						} else {
							secEnd = true;
						}
						break;
					/*case "\r":
						secEnd = true;
						break;*/
					case "\n":
						print("["+("-"*(section.hierarchy-1))+"> セクションの開始 h:${section.hierarchy} title:${section.title}]");
						//this.back();
						secEnd = true;
						break;
					default:
						section.title += token;
						break;
				}
			} else {
				section.children = this.analyze(section, (token) {
					if (token == '#') {
						// 次に始まるセクションの階層を調べる
						// もし自分より上か同階層なら自分のセクションは終了
						
						int nextSectionHierarchy = 1;
						int step = 0;
						this.next();
						this.scan((String secToken) {
							step++;
							if (secToken == '#') {
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
	
	Strong analyzeStrong(Element parent) {
		Strong strong = new Strong();
		strong.parent = parent;
		this.next();
		this.scan((token) {
			switch (token) {
				case '*':
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
	
	Link analyzeLink(Element parent) {
		Link link = new Link();
		link.parent = parent;
		this.next();
		this.scan((token) {
			link.children = this.analyze(link, (token) {
				return token == ']';
			});
			return true;
		});
		// URLが見つかるまで空回し
		this.scan((token){return token == '(';});
		this.next();
		this.scan((token) {
			switch (token) {
				case ')':
					return true;
				default:
					link.url += token;
					break;
			}
		});
		return link;
	}
	
	Image analyzeImage(Element parent) {
		Image img = new Image();
		img.parent = parent;
		this.next();
		this.scan((token) {
			switch (token) {
				case ')':
					return true;
				default:
					img.url += token;
					break;
			}
		});
		return img;
	}
	
	/**
	 * トークンリーダを指定した分だけ進めます。
	 */
	void next([int step = 1]) {
		if ((this.pos + step) < this.source.length) {
			this.pos += step;
		} else {
			this.pos = this.source.length - 1;
		}
	}
	
	/**
	 * トークンリーダを指定した分だけ巻き戻します。
	 */
	void back([int step = 1]) {
		this.pos -= step;
	}
	
	/**
	 * ソースを走査します。トークンに出会う度に指定されたスキャナが呼ばれます。
	 * スキャナが [true] を返した場合、そこで直ちに走査は終了し、関数が終了します。
	 */
	void scan(bool scanner(String token)) {
		while ((this.pos + 1) != this.source.length) {
			String token = this.source[this.pos];
			//print(token);
			if (scanner(token) == true) {
				break;
			}	
			this.next();
		}
	}
}
