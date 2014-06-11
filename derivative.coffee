Grammar = 
  PROGRAM: [
    "ELEMENT*"
  ]

  ELEMENT: [
    "function IDENTIFIER ( IDENTIFIER* ) { STATEMENT* }"
    "STATEMENT"
  ]

  STATEMENT: [
    ";"
    "if ( EXPRESSION ) { STATEMENT* } ELSE?"
    "while ( EXPRESSION ) { STATEMENT* }"
    "return EXPRESSION"
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
    /'.*'|".*"/
  ]

class Language
  constructor: (@grammar) ->

  parse: (source) ->
    tokens = @lex source

    while tokens.length
      @derive tokens.shift(), 'PROGRAM'

  lex: (string) -> 
    string.match ///
      \w+
      | \. | , | ; | :
      | + | - | * | / 
      | == | != | === | !== | =
      | \[ | \]
      | \( | \)
      | \{ | \}
      | '.*' | ".*"
    ///g

  derive: (token, symbol) ->
    if ! symbol
      return

    if symbol is ''
      return
      
    if @const symbol
      if token is symbol
        return ''
      else
        return

    if @alt symbol
      return @grammar[symbol].map((case) => @derive(token, case))

    if @rep symbol
      return "#{@derive(token, symbol.extract(/(\w+)/))} #{symbol}"

    if @cond symbol
      return @derive(token, symbol.extract(/(\w+)/))

    if @cat symbol
      [first, rest...] = symbol.split(' ')
      if @nullability first
        ["#{@derive(token, first)} #{rest.join(' ')}", @derive(token, rest.join(' '))]
      else
        "#{@derive(token, first)} #{rest.join(' ')}"

  nullability: (symbol) ->
    if ! symbol
      return

    if symbol is ''
      return '' 

    if @const symbol
      return

    if @alt symbol
      return @grammar[symbol].map((case) => @nullability(case)).or()

    if @cat symbol
      return symbol.split(' ').map((sub) => @nullability(sub)).and()

    if @rep symbol
      return ''

    if @cond symbol
      return ''

  const: (symbol) -> symbol.isRegexp || ! symbol.contains(' ') && ! @grammar[symbol]?
  alt: (symbol) -> @grammar[symbol]?.length > 1
  cat: (symbol) -> symbol.contains(' ')
  rep: (symbol) -> symbol.contains('*')
  cond: (symbol) -> symbol.contains('?')

  compact: ->

(new Language(Grammar)).parse """
  function a() { return 1; }
"""
