Test = """
  function a() { return 1; }
"""

Grammar = 
  PROGRAM: [
    "(ELEMENT)*"
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
    @tree = 
      symbol: 'program'
      children: []

    while tokens.length
      @derive tokens.shift()

    @tree

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

  derive: (symbol) ->
    ###
    derive c of
      null -> null
      ''   -> null
      c    -> ''
      c'   -> null if c' != c
      A,B  -> derive(A),B if not A.contains ''
      A,B  -> derive(A),B|derive(B) if A.contains ''
      A|B  -> derive(A)|derive(B)
      A*   -> derive(A),A*
    ###

    return if not @grammar

  nullify: (symbol) ->
    if symbol is null
      return null 

    if symbol is ''
      return '' 

    if @const symbol
      return null 

    if @alt symbol
      return @grammar[symbol].map((case) => @nullify(case)).or()

    if @cons symbol
      return @grammar[symbol].map((case) => @nullify(case)).or()


  const: (symbol) -> ! symbol.contains(' ') && ! @grammar[symbol]?
  alt: (symbol) -> @grammar[symbol]?.length > 1
  cons: (symbol) -> symbol.contains(' ')

  compact: ->


(new Language(Grammar)).parse(Test)