part of notex2;

abstract class Element {
	String name;
	Element parent;
	List<Element> children = new List();
	Map<String, String> attributes = new Map();
	
	/**
	 * HTML文字列を生成します。
	 */
	String toHtml([String id = '', int hierarchy = 0]);
	
	/**
	 * 目次のHTML文字列を生成します。
	 */
	String genelateTableOfContentsHtml(String id) {
		// ダックタイピング的な
		if (this.name == 'section') {
			String html = "";
			if (this.childFind('section')) {
				for (Element element in this.children) {
	        			html += element.genelateTableOfContentsHtml(id);
	        		}
	        		return '<li class="section"><a href="#${id}-${this.number}">${this.title}</a><ol>$html</ol></li>';
			} else {
				return '<li><a href="#${id}-${this.number}">${this.title}</a></li>';
			}
		} else {
			return '';
		}
	}
	
	/**
	 * 自分の親に指定された名前を持つ要素が存在するかどうかを取得します。
	 */
	bool parentFind(name) {
		return this.parent.parentSearch(name);
	}
	
	bool parentSearch(String name) {
		if (name == this.name)
			return true;
		else
			return this.parent.parentSearch(name);
	}
	
	/**
	 * 自分の子に指定された名前を持つ要素が存在するかどうかを取得します。
	 */
	bool childFind(String name) {
		for (Element element in this.children) {
			if (element.childSearch(name)) {
				return true;
			}
		}
		return false;
	}
	
	bool childSearch(String name) {
		if (name == this.name) {
			return true;
		} else {
			for (Element element in this.children) {
        			if (element.childSearch(name)) {
        				return true;
        			}
        		}
			return false;
		}
	}
}