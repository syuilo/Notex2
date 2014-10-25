part of Notex2;

class TableData extends Element {
	String name = 'table_data';
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
		return "<td$attribute>$html</td>";
	}
}