/*
 * Copyright (c) 2014 syuilo All rights reserved.
 * Thanks for Akari, Chinatsu, Yui, Kyoko and you.
 *                                                      syuilo
 **************************************************************** */

library Notex2;

/*
 * Import Scanner
 */
part "scanner.dart";

/*
 * Import Parser
 */
part "parser.dart";

/*
 * Import lexcal analyzer
 */
part "lexer.dart";

/*
 * Import elements
 */
part "Elements/element.dart";
part "Elements/article.dart";
part "Elements/blockquote.dart";
part "Elements/code.dart";
part "Elements/image.dart";
part "Elements/keyword.dart";
part "Elements/link.dart";
part "Elements/list.dart";
part "Elements/list_item.dart";
part "Elements/multilinecode.dart";
part "Elements/paragraph.dart";
part "Elements/section.dart";
part "Elements/strike.dart";
part "Elements/strong.dart";
part "Elements/text.dart";


void scream() {
	print("うー！にゃー！" * 4);
}

String indent(int hierarchy) {
	//return ("\t" * hierarchy);
	return ("    " * hierarchy);
}

String htmlEscape(String source) {
	String html = source;
	html = html.replaceAll('<', '&lt;');
	html = html.replaceAll('>', '&gt;');
	return html;
}

/**
 * Token
 */
class Token {
	int id = 0;
	String token = "";
	String lexeme = "";
}

/**
 * コンパイラ本体です。
 */
class Notex2 {
	String source;
	String id = "article";
	
	Parser parser;
	
	Notex2(String source, [String articleId = "article"]) {
		this.source = source;
		this.id = articleId;
	}
	
	Article compile() {
		this.parser = new Parser(new Scanner(new Lexer(this.source).analyze()));
		
		Article article = new Article();
		article.title = this.id;
		article.children = this.parser.analyze(article, (token){return false;});
		return article;
	}
}
