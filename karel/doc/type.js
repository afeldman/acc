type_decl := Diagram(Terminal('type'),  OneOrMore(Sequence(NonTerminal('identifier'),Optional(Sequence('from','identifier')),'=',NonTerminal('user type'))))
