Grammar = 
  program: [
    ''
    'element program'
  ]

  element: [
    'function identifier ( parameterlistopt ) compoundstatement'
    'statement'
  ]

  parameterlistopt: [
    'empty'
    'parameterlist'
  ]

  parameterlist: [
    'identifier'
    'identifier parameterlist'
  ]

  compoundstatement: [
    '{ statements }'
  ]

  statements: [
    'empty'
    'statement statements'
  ]

  statement: [
    ';'
    'if condition statement'
    'if condition statement else statement'
    'while condition statement'
  ]

class Language
  constructor: (@grammar) ->

  parse: (source) ->
    tokens = @lex source
    @tree = program: []

    while tokens.length
      @derive tokens.shift()

    @tree

  lex: (string) -> 
    string.match ///
      \w+
    | \.
    | ;
    | \[
    | \]
    | \(
    | \)
    | '.*'
    | ".*"
    ///

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

  nullify: -> nullity 



  compact: ->

