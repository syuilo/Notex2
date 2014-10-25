part of Notex2;

class Section extends Element {
	String name = 'section';
	int hierarchy;
	String title = "";
	int number = 0;
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		String attribute = "";
		String h = "h$hierarchy";
		for (Element element in this.children) {
			html += element.toHtml(id, hierarchy + 1);
		}
		/*
		for (String key in this.attributes.keys) {
			attribute += ' $key="${this.attributes[key]}"';
                }
                */
		if (id != '') {
			attribute = ' id="#${id}-${this.number}"';
		}
		return indent(hierarchy) + "<section$attribute>\n"
				+ indent(hierarchy + 1) + "<$h>$title</$h>\n"
				+ html
				+ indent(hierarchy) + "</section>\n";
	}
	
	static bool check(Scanner scanner, Token token) {
		return
			(token.token == 'newline') &&
			(scanner.pick(token.id + 1).token == 'sharp');
	}
	
	static Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
        	if (filter != null) {
        		if (filter.indexOf('section') > -1) {
        			return null;
        		}
        	}
        	return generate(parser, parent);
        }

	static Section generate(Parser parser, Element parent) {
		parser.sectionCount++;
        	Section section = new Section();
        	section.parent = parent;
        	section.hierarchy = 0;
        	section.title = "";
        	section.number = parser.sectionCount;
        	bool secEnd = false;
        	
        	parser.scanner.next();
        	parser.scanner.scan((Token token) {
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
        					//print("["+("-"*(section.hierarchy-1))+"> セクションの開始 h:${section.hierarchy} title:${section.title}]");
        					parser.scanner.back();
        					secEnd = true;
        					break;
        				default:
        					section.title += token.lexeme;
        					break;
        			}
        		} else {
        			section.children = parser.analyze(section, (token) {
        				if (check(parser.scanner, token)) {
        					// 次に始まるセクションの階層を調べる
        					// もし自分より上か同階層なら自分のセクションは終了
        					
        					int nextSectionHierarchy = 0;
        					int step = 0;
        					parser.scanner.next();
        					parser.scanner.scan((Token secToken) {
        						if (secToken.token == 'sharp') {
        							nextSectionHierarchy++;
        							step++;
        							parser.scanner.next();
        							return false;
        						} else {
        							return true;
        						}
        						step++;
        						parser.scanner.next();
        					});
        					// 階層を調べるために進めたトークンリーダを元の位置まで巻き戻す
        					parser.scanner.back(step + 1);
        					if (nextSectionHierarchy <= section.hierarchy) {
        						parser.scanner.back();
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
        		parser.scanner.next();
        	});
        	
        	//print("["+("-"*(section.hierarchy-1))+"< セクションの終了 h:${section.hierarchy} title:${section.title}]");
        	section.title = htmlEscape(section.title.trim());
        	return section;	
        }
}
