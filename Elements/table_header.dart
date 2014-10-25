part of Notex2;

class TableHeader extends Element {
	String name = 'table_header';
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return "<th>$html</th>";
	}
}