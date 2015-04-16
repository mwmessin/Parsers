Function::implement = (members) ->
  for key of members
    if members[key] != @prototype[key]
      console.warn "overwriting #{key} in #{@name || this}.prototype" if @prototype.hasOwnProperty key
      Object.defineProperty @prototype, key, value: members[key], enumerable: false

Function.implement
  memoize: (memo = {}) ->
    callback = this
    -> memo[JSON.stringify arguments] ||= callback.apply this, arguments

  leastFixedPoint: ->
    callback = this
    -> callback.apply this, arguments

String::contains = (string) -> @indexOf(string) != -1

class Language
  constructor: (@lexeme, @grammar) ->

  parse: (source) ->
    @tokens = @lex source

    while tokens.length
      for symbol in @grammar
        @derive @tokens.shift(), symbol

  lex: (string) -> 
    string.match @lexeme

  derive: ((token, symbol) ->
    if ! symbol
      return

    if symbol is ''
      return
    
    if @constant symbol
      if token is symbol
        return ''
      else
        return

    if @alternatives symbol
      return => @grammar[symbol].map((alt) => @derive(token, alt)) #lazy

    if @repeating symbol
      return => "#{@derive(token, symbol.extract(/(\w+)/))} #{symbol}" #lazy

    if @conditional symbol
      return => @derive(token, symbol.extract(/(\w+)/)) #lazy

    if @concatenation symbol
      [first, rest...] = symbol.split(' ')
      if @nullability first
        => ["#{@derive(token, first)} #{rest.join(' ')}", @derive(token, rest.join(' '))] #lazy
      else
        => "#{@derive(token, first)} #{rest.join(' ')}" #lazy
  ).memoize()

  nullability: ((symbol) ->
    # while (some node's nullability changed) {
    #    update the nullability for every node in the grammar
    # }
    if ! symbol
      return

    if symbol is ''
      return '' 

    if @constant symbol
      return

    if @alternatives symbol
      return @grammar[symbol].map((alt) => @nullability(alt)).or()

    if @concatenation symbol
      return symbol.split(' ').map((sub) => @nullability(sub)).and()

    if @repeating symbol
      return ''

    if @conditional symbol
      return ''
  ).leastFixedPoint() #?

  constant: (symbol) -> symbol.isRegexp || ! symbol.contains(' ') && ! @grammar[symbol]?
  alternatives: (symbol) -> @grammar[symbol]?.length > 1
  concatenation: (symbol) -> symbol.contains(' ')
  repeating: (symbol) -> symbol.contains('*')
  conditional: (symbol) -> symbol.contains('?')

  compact: -> #? key to performance

Javascript = new Language(
  ///
    \w+
    | \. | , | ; | :
    | \+ | - | \* | / 
    | == | != | === | !== | =
    | \[ | \]
    | \( | \)
    | \{ | \}
    | '[^']*' | "[^"]*"
  ///g,
  {
    PROGRAM: [
      "ELEMENT*"
    ]

    ELEMENT: [
      "function IDENTIFIER ( IDENTIFIER* ) { STATEMENT* }"
      "STATEMENT"
    ]

    STATEMENT: [
      "if ( EXPRESSION ) { STATEMENT* } ELSE?"
      "while ( EXPRESSION ) { STATEMENT* }"
      "return EXPRESSION ;"
    ]

    ELSE: [
      "else STATEMENT"
    ]

    EXPRESSION: [
      "IDENTIFIER"
      "STRING"
      "true"
      "false"
      /\d/
    ]

    IDENTIFIER: [
      /\w+/
    ]

    STRING: [
      /'[^']*'|"[^"]*"/
    ]
  }
)

Javascript.parse """
  function a() { return 1; }
"""
