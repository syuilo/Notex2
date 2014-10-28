part of notex2;

class Lexer {
	String source;
	
	Lexer(String source) {
		this.source = source;
	}
	
	/**
         * 字句解析器。トークンリストを生成します。
         */
        List<Token> analyze() {
        	List<Token> tokens = new List();
        	int pos = 0;
        	int id = 0;
        	
        	int row = 1;
        	int col = 1;
        	
        	Token tokeniza() {
                	Token token = new Token();
                	token.row = row;
                	token.col = col;
                	bool text = false;
                	if (this.source.length == 0) {
                		return null;
                	}
                	while (pos < this.source.length) {
                		String char = this.source[pos];
                		pos++;
                		switch (char) {
                			case '\\':
                				if (!text) {
                					token.token = 'escape';
                					token.lexeme = char;
                				} else {
                					pos--;
                				}
                				return token;
                			case ' ':
                				if (!text) {
                					token.token = 'space';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '\n':
                				if (!text) {
                					token.token = 'newline';
                					token.lexeme = char;
                					row++;
                					col = 1;
                				} else {
                					pos--;
                				}
                				return token;
                			case '0':
                			case '1':
                			case '2':
                			case '3':
                			case '4':
                			case '5':
                			case '6':
                			case '7':
                			case '8':
                			case '9':
                				if (!text) {
                					token.token = 'number';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '\'':
                				if (!text) {
                					token.token = 'quotation';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                				
                			case '\"':
                				if (!text) {
                					token.token = 'double_quotation';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '.':
                				if (!text) {
                					token.token = 'period';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case ',':
                				if (!text) {
                					token.token = 'comma';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '@':
                				if (!text) {
                					token.token = 'at_mark';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '#':
                				if (!text) {
                					token.token = 'sharp';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '*':
                				if (!text) {
                					token.token = 'asterisk';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '-':
                				if (!text) {
                					token.token = 'hyphen';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '~':
                				if (!text) {
                					token.token = 'tilde';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '|':
                				if (!text) {
                					token.token = 'vertical_bar';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '(':
                				if (!text) {
                					token.token = 'open_bracket';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case ')':
                				if (!text) {
                					token.token = 'close_bracket';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '[':
                				if (!text) {
                					token.token = 'open_square_bracket';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case ']':
                				if (!text) {
                					token.token = 'close_square_bracket';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '{':
                				if (!text) {
                					token.token = 'open_curly_bracket';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '}':
                				if (!text) {
                					token.token = 'close_curly_bracket';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '<':
                				if (!text) {
                					token.token = 'greater_than';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '>':
                				if (!text) {
                					token.token = 'less_than';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			case '!':
                				if (!text) {
                					token.token = 'exclamation_mark';
                					token.lexeme = char;
                					col++;
                				} else {
                					pos--;
                				}
                				return token;
                			default:
                				text = true;
                				token.token = 'text';
                				token.lexeme += char;
                				col++;
                				break;
                		}
                	}
                	return token;
                }
        	
        	while (pos < this.source.length) {
        		var token = tokeniza();
        		token.id = id;
        		id++;
        		//print("${token.id}\t${token.token}\t: ${token.lexeme}");
        		tokens.add(token);
        	}
        	
        	Token token = new Token();
        	token.id = id;
        	token.token = 'eof';
        	token.lexeme = '';
        	tokens.add(token);
        	
        	return tokens;
        }
}
