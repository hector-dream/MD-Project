# Queries

# Qual a ordem crescente da média de notas de cada ano?
ano(Ano) :-
    episodio(_, _, _, Ano, _, _, _, _).

media_nota_ano(Ano, Media) :-
    findall(M, episodio(_, _, _, Ano, _, _, M, _), Lista),
    sum_list(Lista, Soma),
    length(Lista, Qtd),
    Media is Soma / Qtd.

# query
setof(A, media_nota_ano(A, Media), Ano).