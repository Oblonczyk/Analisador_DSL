extends SceneTree

enum TokenType{
	# Comands
	DEFINE_COMBO, EXECUTE_COMBO, UPDATE_SCORE,
	
	# Key_words and Values
	IDENTIFIER,  # Parameter names (name, sequence) and butons (punch, kick)
	INTEGER,     # Numbers (10, 2)
	STRING,      # Texte in quots ("Punch")
	PLAYER_ID,   # player_1, player_2
	
	# Symbols
	LPAREN, RPAREN,     # ()
	LBRACKET, RBRACKET, # []
	EQUALS, COMMA,      # =,
	
	# Control
	EOF # File end
}

class Token:
	var type: TokenType
	var value
	func _init(param_type: TokenType, param_value = null):
		self.type = param_type
		self.value = param_value

	func _to_string() -> String:
		return "Token({type}, {value})".format({"type": TokenType.keys()[type], "value": value})
		
# LEXICAL ANALYSIS
func tokenize(source: String) -> Array[Token]:
	var tokens: Array[Token] = []
	var current = 0
	
	var letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	while current < source.length():
		var char = source[current]
		
		if char == ' ' or char == '\t' or char == '\n':
			current += 1;continue
			
		match char:
			'(': tokens.push_back(Token.new(TokenType.LPAREN, char)); current += 1; continue
			')': tokens.push_back(Token.new(TokenType.RPAREN, char)); current += 1; continue
			'[': tokens.push_back(Token.new(TokenType.LBRACKET, char)); current += 1; continue
			']': tokens.push_back(Token.new(TokenType.RBRACKET, char)); current += 1; continue
			'=': tokens.push_back(Token.new(TokenType.EQUALS, char)); current += 1; continue
			',': tokens.push_back(Token.new(TokenType.COMMA, char)); current += 1; continue
			
		if char == '"':
			var str_value = ""
			current += 1 # Ignore the inicial quote
			while current < source.length() and source[current] != '"':
				str_value += source[current]
				current += 1
			if current >= source.length():
				push_error("Lexical Error: Str didn't finish with QUOTATION MARKS")
				return []
			current += 1
			tokens.push_back(Token.new(TokenType.STRING, str_value))
			continue
		
		if char.is_valid_int():
			var num_str = ""
			while current < source.length() and source[current].is_valid_int():
				num_str += source[current]
				current += 1
			tokens.push_back(Token.new(TokenType.INTEGER, int(num_str)))
			continue
			
		if letters.find(char) != -1:
			var identifier = ""
			while current < source.length() and (letters.find(source[current]) != -1 or source[current].is_valid_int() or source[current] == '_'):
				identifier += source[current]
				current += 1
				
			match identifier:
				"define_combo": tokens.push_back(Token.new(TokenType.DEFINE_COMBO, identifier))
				"execute_combo": tokens.push_back(Token.new(TokenType.EXECUTE_COMBO, identifier))
				"update_score": tokens.push_back(Token.new(TokenType.UPDATE_SCORE, identifier))
				"player_1", "player_2": tokens.push_back(Token.new(TokenType.PLAYER_ID, identifier))
				_: tokens.push_back(Token.new(TokenType.IDENTIFIER, identifier))
			continue
			
		push_error("Lexical error: Unespected char '{char}'.".format({"char": char}))
		return []
	
	tokens.push_back(Token.new(TokenType.EOF))
	return tokens
	
# Sintatical Analysis
var tokens: Array[Token]
var pos: int

func parse(param_tokens: Array[Token]) -> bool:
	tokens = param_tokens
	pos = 0
	if tokens.is_empty(): return false
	
	while not is_at_end():
		if not comand_parse(): return false
	return true
	
# Rules <comand> ::= <cmd_define_combo> | <cmd_execute_combo> | <cmd_update_score>
func comand_parse() -> bool:
	if match_token(TokenType.DEFINE_COMBO): return parse_define_combo()
	if match_token(TokenType.EXECUTE_COMBO): return parse_execute_combo()
	if match_token(TokenType.UPDATE_SCORE): return parse_update_score()
	
	push_error("Sintatical Error: unknowed comand or unspected: {token}".format({"token": peek().to_string()}))
	return false
	
# Sintaxe validator for define_combo()
func parse_define_combo() -> bool:
	if not consume(TokenType.LPAREN, "Expected '(' after 'define_combo'."): return false
	if not parse_list_params(): return false
	if not consume(TokenType.RPAREN, "Expected ')' to finish comand."): return false
	return true
	
func parse_execute_combo() -> bool:
	if not consume(TokenType.LPAREN, "Expected '(' after 'execute_combo'."): return false
	if not parse_list_params(): return false
	if not consume(TokenType.RPAREN, "Expected ')' to finish comand."): return false
	return true

# Sintaxe validator for update_score()
func parse_update_score() -> bool:
	if not consume(TokenType.LPAREN, "Expected '(' after 'update_score'."): return false
	if not parse_list_params(): return false
	if not consume(TokenType.RPAREN, "Expected ')' to finish comand."): return false
	return true
	
# General rule to lists of parameters: p1=v1, p2=v2
func parse_list_params() -> bool:
	if not parse_param(): return false
	while match_token(TokenType.COMMA):
		if not parse_param():
			push_error("Sintatical Error: Expected a parameter after comma")
			return false
	return true
	
# Parameter rules: NAME = VALUE
# The VALUE can be a INTEGER, STRING, PLAYER_ID or a BUTTON LIST
func parse_param() -> bool:
	if not consume(TokenType.IDENTIFIER, "Expected parameter name (ex: 'name')."): return false
	if not consume(TokenType.EQUALS, "Expected '=' after the parameter name."): return false
	
	if peek().type == TokenType.INTEGER or \
	   peek().type == TokenType.STRING or \
	   peek().type == TokenType.PLAYER_ID:
		advance()
		return true
	
	if peek().type == TokenType.LBRACKET:
		return parse_button_list()
	
	push_error("Sintax Error: Invalid or Unexpected parameter value: {token}".format({"token": peek().to_string()}))
	return false
	
# Validation rule for a button list: [button1, button2, button3, ...]
func parse_button_list() -> bool:
	if not consume(TokenType.LBRACKET, "Expected '[' to init the button list."): return false
	
	# Verify the list is not empty
	if peek().type != TokenType.RBRACKET:
		if not consume(TokenType.IDENTIFIER, "Expected a button identifier (ex: 'punch')."): return false
		while match_token(TokenType.COMMA):
			if not consume(TokenType.IDENTIFIER, "Expected a button identifier after comma."): return false
	
	if not consume(TokenType.RBRACKET, "Expected ']' to finish the button list."): return false
	return true
	
func peek() -> Token: return tokens[pos]

func advance() -> Token:
	if not is_at_end(): pos += 1
	return tokens[pos - 1]
	
func is_at_end() -> bool: return peek().type == TokenType.EOF

func consume(type: TokenType, message: String) -> bool:
	if peek().type == type: advance(); return true
	push_error("Erro Sintático: " + message); return false
	
func match_token(type: TokenType) -> bool:
	if peek().type == type: advance(); return true
	return false
	
func _init():
	var arguments = OS.get_cmdline_args()
	if arguments.size() < 2:
		print("USE: godot --headless --script analisador.gd <file_path>")
		quit(1)
		
	var file_path = arguments[arguments.size() - 1]
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not FileAccess.file_exists(file_path) or file == null:
		printerr("Error: Is not possible open the file: ", file_path)
		quit(1)
		
	var content = file.get_as_text()
	file.close()

	print("--- File analisys initializing: {path} ---".format({"path": file_path}))
	var tokens_result = tokenize(content)
	if tokens_result.is_empty() and content.strip_edges().length() > 0:
		print("--- Analysis Failed (Lexical Error) ---")
		quit(1)

	if parse(tokens_result):
		print("SUCESS: The script sintax is valid!")
		quit(0)
	else:
		print("ERROR: The script has sintax erros.")
		quit(1)
