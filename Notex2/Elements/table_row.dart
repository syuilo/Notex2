part of Notex2;

class TableRow extends Element {
	String name = 'table_row';
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		for (Element element in this.children) {
			html += element.toHtml();
		}
		return indent(hierarchy) + "<tr>$html</tr>\n";
	}
}