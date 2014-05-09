Grammar = 



class Language
  constructor: (@grammar) ->

  lex: (string) -> tokens

  derive: (character) ->
    ###
    derive(c) of
      null -> null
      ''   -> null
      c    -> ''
      c'   -> null if c' != c
      A,B  -> derive(A),B if not A.contains ''
      A,B  -> derive(A),B|derive(B) if A.contains ''
      A|B  -> derive(A)|derive(B)
    ###

    return if not @grammar



  compact: ->

