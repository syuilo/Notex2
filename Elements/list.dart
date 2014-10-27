part of Notex2;

class EList extends Element {
	String name = 'list';
	String type = "unordered"; // unordered or ordered
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml(id, hierarchy + 1);
		}
		String tag = this.type == 'ordered' ? 'ol' : 'ul';
		if (this.parent.name == 'list_item') {
			return '\n' + indent(hierarchy) + "<$tag>\n$html" + indent(hierarchy) + "</$tag>\n" + indent(hierarchy - 1);
		} else {
			return indent(hierarchy) + "<$tag>\n$html" + indent(hierarchy) + "</$tag>\n";
		}
	}
	
	static bool check(Scanner scanner, Token token) {
        	return
        		token.token == 'newline' && (
        			scanner.pick(token.id + 1).token == 'hyphen' || (
        				scanner.pick(token.id + 1).token == 'number' &&
        				scanner.pick(token.id + 2).token == 'period'
        			)
        		);
        }

        static Element analyze(Parser parser, Element parent, [inspecter(Token token), List<String> filter]) {
        	if (filter != null) {
        		if (filter.indexOf('list') > -1) {
        			return null;
        		}
        	}
        	return generate(parser, parent);
        }
        
       static EList generate(Parser parser, Element parent) {
	       Token startToken = parser.scanner.read();
		EList list = new EList();
		list.parent = parent;
		parser.scanner.next();
		int hierarchy = 0;
		parser.scanner.scan((Token token) {
			if (token.token == 'hyphen') {
				hierarchy++;
				list.type = 'unordered';
			} else if (token.token == 'number' && parser.scanner.pick(token.id + 1).token == 'period') {
				hierarchy++;
                               	list.type = 'ordered';
                               	parser.scanner.next();
			} else if (token.token == 'space') {
				
			} else {
				return true;
			}
			parser.scanner.next();
		});
		if (list.type == 'ordered') {
			parser.scanner.back(2);
		} else {
			parser.scanner.back();
		}
		
		parser.scanner.scan((Token token) {
			if (list.type == 'ordered') {
				parser.scanner.next(2);
			} else {
				parser.scanner.next();
			}
			EListItem item = new EListItem();
			item.parent = list;
			EList childList;
			String childListType = '';
			bool exit = false;
			int nextHierarchy = 0;
			item.children = parser.analyze(item, (token) {
				if (
					parser.scanner.pick(token.id).token == 'newline' && (
						parser.scanner.pick(token.id + 1).token == 'hyphen' || (
        						parser.scanner.pick(token.id + 1).token == 'number' && parser.scanner.pick(token.id + 2).token == 'period'
        					)
        				)
        			) {
					if (parser.scanner.pick(token.id + 1).token == 'number' && parser.scanner.pick(token.id + 2).token == 'period') {
						childListType = 'ordered';
						parser.scanner.next(2);
					} else {
						childListType = 'unordered';
						parser.scanner.next();
					}
        				nextHierarchy = getNextHierarchy(parser);
        				int nextStep = getNextStep(parser);
        		       		if (hierarchy > nextHierarchy) {
        		       			// 昇る時
        		       			parser.scanner.back(2);
        		       			exit = true;
                               			return true;
                               		} else if (hierarchy == nextHierarchy) {
                               			// 兄弟
                        			if (list.type == 'ordered') {
                        				parser.scanner.next(nextStep - 3);
                        			} else {
                        				parser.scanner.next(nextStep - 2);
                        			}
                               		} else { // hierarchy < nextHierarchy
                               			// 潜る時
                               			parser.scanner.back();
                               			childList = new EList();
                               			childList.parent = item;
                        			childList = EList.generate(parser, childList);
                               		}
        			}
				return token.token == 'newline';
			}, ['paragraph']);
			if (exit) {
				if (item.children.length != 0) {
					list.children.add(item);
				}
				return true;
			}
			if (childList != null) {
				childList.parent = item;
				item.children.add(childList);
			}
			if (item.children.length != 0) {
				list.children.add(item);
			}
			if (parser.scanner.read(1).token == 'newline') {
				parser.scanner.next();
				return true;
			}
			parser.scanner.next();
		}, () {
			parser.addError(new Error(
				'${startToken.row}行目の${startToken.col}列目あたりから始まった List(- または 数字.) が閉じていません。',
				startToken.row,
				startToken.col
				));
		});
		parser.scanner.back();
		return list;
	}
       
	static int getNextHierarchy(Parser parser) {
		int step = 0;
		int nextHierarchy = 0;
		parser.scanner.scan((Token token) {
			if (token.token == 'hyphen') {
				nextHierarchy++;
			} else if (token.token == 'number' && parser.scanner.pick(token.id + 1).token == 'period') {
				nextHierarchy++;
				step++;
				parser.scanner.next();
			} else if (token.token == 'space') {
				
			} else {
				return true;
			}
			step++;
			parser.scanner.next();
		});
		// 階層を調べるために進めたトークンリーダを元の位置まで巻き戻す
       		parser.scanner.back(step);
       		return nextHierarchy;
	}
	
	static int getNextStep(Parser parser) {
		int step = 0;
		int nextStep = 0;
		parser.scanner.scan((Token token) {
			if (token.token == 'hyphen') {
				nextStep++;
			} else if (token.token == 'number' && parser.scanner.pick(token.id + 1).token == 'period') {
				nextStep++;
				nextStep++;
				step++;
				parser.scanner.next();
			} else if (token.token == 'space') {
				
			} else {
				return true;
			}
			step++;
			parser.scanner.next();
		});
		// 階層を調べるために進めたトークンリーダを元の位置まで巻き戻す
       		parser.scanner.back(step);
       		return nextStep;
	}
}
