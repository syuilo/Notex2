part of Notex2;

class EListItem extends Element {
	String name = 'list_item';
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml(id, hierarchy + 1);
		}
		return indent(hierarchy) + "<li>$html</li>\n";
	}
}