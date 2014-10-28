part of notex2;

class TableHeader extends Element {
	String name = 'table_header';
	int colspan = 0, rowspan = 0;
	
	String toHtml([String id = '', int hierarchy = 0]) {
		String html = "";
		String attribute = "";
		if (this.colspan > 0) {
			attribute += ' colspan="$colspan"';
		}
		if (this.rowspan > 0) {
			attribute += ' rowspan="$rowspan"';
		}
		for (Element element in this.children) {
			html += element.toHtml();
		}
		html = html.trim();
		return "<th$attribute>$html</th>";
	}
}