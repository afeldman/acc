const_ := Diagram(
  Terminal('const'),
  OneOrMore(Sequence(NonTerminal('identifier'),'=',Choice(1,'+',Skip(),'-'),NonTerminal('constant'))),
)
