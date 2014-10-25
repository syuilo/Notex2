part of Notex2;

class TableData extends Element {
	String name = 'table_data';
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return "<td>$html</td>";
	}
}