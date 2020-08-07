statement := Diagram(
Sequence(Choice(0,Sequence(NonTerminal("identifier"),"::"),Skip())),
         Choice(3,NonTerminal("go to statement"),
                   NonTerminal("for statement"),
                   NonTerminal("if statement"),
                   NonTerminal("return statement"),
                   NonTerminal("select statement"),
                   NonTerminal("while statement"),
                   NonTerminal("repeat statement"), 
         )
)
