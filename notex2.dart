/*
interface IElement {
	String toHtml();
}
*/

library Notex2;

String indent(int hierarchy) {
	return ("  " * hierarchy);
}

abstract class Element {
	String toHtml([int hierarchy = 0]);
}

class Text extends Element {
	String text = "";
	String toHtml([int hierarchy = 0]) {
		return this.text.replaceAll(new RegExp(r'\n'), '</br>');
	}
}

class Article extends Element {
	List<Element> children;
	
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
	List<Element> children;
	
	Section() {
		this.children = new List();
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
	List<Element> children;
	
	Paragraph() {
		this.children = new List();
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
	List<Element> children;
	
	Strong() {
		this.children = new List();
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
	List<Element> children;
	
	Link() {
		this.children = new List();
	}
	
	String toHtml([int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return "<a href=\"$url\" target=\"_blank\">$html</a>";
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
		article.children = this.analyze((token){return false;});
		return article;
	}
	
	List<Element> analyze([inspecter(token)]) {
		List<Element> elements = new List();
		this.scan((token) {
			if (inspecter != null) {
				if (inspecter(token)) {
					return true;
				}
			}
			switch (token) {
				case '#': // Section
					elements.add(this.analyzeSection());
					break;
				case '*': // Strong
					elements.add(this.analyzeStrong());
					break;
				case '[': // Link
					elements.add(this.analyzeLink());
					break;
				default:
					elements.add(this.analyzeParagraph());
					break;
			}
		});
		return elements;
	}
	
	Section analyzeSection() {
		Section section = new Section();
		section.hierarchy = 1;
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
						this.back(1);
						secEnd = true;
						break;
					default:
						section.title += token;
						break;
				}
			} else {
				section.children = this.analyze((token) {
					if (token == '#') {
						// 次に始まるセクションの階層を調べる
						// もし自分より上か同階層なら自分のセクションは終了
						
						int nextSectionHierarchy = 1;
						int step = 0;
						this.scan((String secToken) {
							step++;
							if (secToken == '#') {
								nextSectionHierarchy++;
								return false;
							} else {
								//print("${nextSectionHierarchy} ${secToken}");
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
	
	Text analyzeText() {
		Text text = new Text();
		this.back();
		this.scan((token) {
			switch (token) {
				case '*':
					this.back();
					return true;
				case '[':
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
	
	Paragraph analyzeParagraph() {
		Paragraph p = new Paragraph();
		this.back();
		this.scan((token) {
			switch (token) {
				case '#':
					this.back();
					return true;
				case '*':
					p.children.add(this.analyzeStrong());
					break;
				case '[':
					p.children.add(this.analyzeLink());
					break;
				default:
					p.children.add(this.analyzeText());
					break;
			}
		});
		return p;
	}
	
	Strong analyzeStrong() {
		Strong strong = new Strong();
		this.scan((token) {
			switch (token) {
				case '*':
					this.next();
					return true;
				default:
					strong.children.add(this.analyzeText());
					this.next();
					return true;
			}
		});
		return strong;
	}
	
	Link analyzeLink() {
		this.back();
		Link link = new Link();
		this.scan((token) {
			switch (token) {
				case '\$':
					this.next();
					return true;
				default:
					link.children = this.analyze((token) {
						return token == ']';
					});
					return true;
			}
		});
		/*this.scan((token) {
			switch (token) {
				case ')':
					this.next();
					return true;
				default:
					link.url += token;
					break;
			}
		});*/
		return link;
	}
	
	void next([int step = 1]) {
		this.pos += step;
	}
	
	void back([int step = 1) {
		this.pos -= step;
	}

	scan(bool scanner(String token)) {
		while (this.pos != this.source.length) {
			String token = this.source[this.pos];
			//print(token);
			this.next();
			if (scanner(token) == true) {
				break;
			}
		}
	}
}