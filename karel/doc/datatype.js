datatype := Diagram(
Choice(4,NonTerminal('identifier'),Terminal('integer'),Terminal('real'),Terminal('boolean'),Terminal('vector'),Terminal('file'),Sequence(Terminal('string'),Terminal('['),NonTerminal('unsinged integer'),Terminal(']')), Sequence(Terminal('array'),Terminal('['),OneOrMore(NonTerminal('unsinged integer'),Choice(1,'*',',')),Terminal(']'),Terminal('of'),Terminal('structure array type')))
)
