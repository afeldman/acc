variable := Diagram(
  Terminal('var'), Sequence(OneOrMore(Sequence(OneOrMore('identifier',','),Choice(1,Skip(),Sequence(Terminal('from'),NonTerminal('identifier'))),':',NonTerminal('data type'))))
)
