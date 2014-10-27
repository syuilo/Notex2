part of Notex2;

/**
 * トークンリーダ
 */
class Scanner {
	List<Token> tokens;
	int pos = -1;
	
	Scanner(List<Token> tokens) {
		this.tokens = tokens;
	}
	
	/**
	 * 指定された位置にあるトークンを読み出します。
	 */
	Token pick(int pos) {
		if (pos >= this.tokens.length) {
			Token token = new Token();
			token.token = 'null';
			token.lexeme = '';
			return token;
			//throw new Exception("Reader over");
		} else if (pos == -1) {
			Token token = new Token();
			token.id = -1;
			token.token = 'newline';
			token.lexeme = '\n';
			return token;
		} else if (pos < 0) {
			Token token = new Token();
			token.token = 'null';
			token.lexeme = '';
			return token;
			//throw new Exception("Reader over");
		} else {
			return this.tokens[pos];
		}
	}
	
	/**
	 * トークンリーダを指定した分だけ進めます。
	 */
	void next([int step = 1]) {
		this.pos += step;
	}
	
	/**
	 * トークンリーダを指定した分だけ巻き戻します。
	 */
	void back([int step = 1]) {
		this.pos -= step;
	}
	
	/**
	 * 現在のトークンリーダの位置にあるトークンを読み出します。
	 */
	Token read([int relative_pos = 0]) {
		int pos = this.pos + relative_pos;
		return this.pick(pos);
	}
	
	/**
	 * ソースを走査します。トークンに出会う度に指定されたスキャナが呼ばれます。
	 * スキャナが [true] を返した場合、そこで直ちに走査は終了し、関数が終了します。
	 */
	void scan(bool scanner(Token token), [scanEnd()]) {
		while ((this.pos) < this.tokens.length) {
			Token token = this.read();
			//print(token);
			if (scanner(token) == true) {
				break;
			}	
		}
		if (scanEnd != null) {
			if (this.pos >= (this.tokens.length - 1)) {
				scanEnd();
			}
		}
	}
}