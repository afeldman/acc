program := Diagram(
  Terminal('Program'),
  NonTerminal('identifier'),
  OptionalSequence('Var decleration','Const decleration','Type decleration'),
  ZeroOrMore('ROUTINE decleration'),
  Sequence('begin','statement list', 'end'),
  NonTerminal('identifier'),
  ZeroOrMore('Routine definition')
)
