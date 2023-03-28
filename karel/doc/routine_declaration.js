routine_decl := Diagram(
Sequence('routine',NonTerminal('identifier'),
OptionalSequence(Sequence('(',OneOrMore(NonTerminal('identifier'),','),':',NonTerminal('data type'),')'),Sequence(Terminal(':'),NonTerminal('data type'))),
Choice(1,Sequence('from',NonTerminal('identifier')),OneOrMore(Choice(0,'var declaration','conts declaration'),Sequence('begin',NonTerminal('statement list'),'end',NonTerminal('identifier')))))
)
