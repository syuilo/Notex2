part of Notex2;

/**
 * ArticleはElement木の根ノードです。
 */
class Article extends Element {
	String name = 'article';
	String title = "";
	
	bool parentFind(name) {
		return false;
	}
	
	bool parentSearch(String name) {
		if (name == 'article')
			return true;
		else
			return false;
	}
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml(id, hierarchy + 1);
		}
		return "<!-- Generated by Notex2 (c) syuilo. -->\n<article>\n$html</article>";
	}
	
	String genelateTableOfContentsHtml(String id) {
		String html = "";
		for (Element element in this.children) {
			html += element.genelateTableOfContentsHtml(id);
		}
		return '<div class="tableOfContents" id="${id}-tableOfContents"><ol>$html</ol></div>';
	}
}