ano(Ano) :-
    episodio(_, _, _, Ano, _, _, _, _).

media_nota_ano(Ano, Media) :-
    ano(Ano),
    findall(N, episodio(_, _, _, Ano, _, _, N, _), Lista),
    sum_list(Lista, Soma),
    length(Lista, Qtd),
    Media is Soma / Qtd.

ordenando_medias_anos(Anos) :-
    setof((M - A), media_nota_ano(A, M), ListaAnos),
    reverse(ListaAnos, Anos).

diretor(Diretor) :-
    episodio(_, _, _, _, _, Diretor, _, _).

quantidade_ep_dirigidos(Diretor, Quantidade) :-
    diretor(Diretor),
    findall(E, episodio(E, _, _, _, _, Diretor, _, _), Lista),
    length(Lista, Quantidade).

principal_diretor(Diretor) :-
    setof((Q, D), quantidade_ep_dirigidos(D, Q), ListaDiretores),
    reverse(ListaDiretores, [(_, Diretor) | _]).

temporada(Temporada) :-
    episodio(_, Temporada, _, _, _, _, _, _).

media_nota_temporada(Temporada, MediaNota) :-
    temporada(Temporada),
    findall(N, episodio(_, Temporada, _, _, _, _, N, _), Lista),
    sum_list(Lista, Soma),
    length(Lista, Qtd),
    MediaNota is Soma / Qtd.

media_votos_temporada(Temporada, MediaVotos) :-
    temporada(Temporada),
    findall(V, episodio(_, Temporada, _, _, _, _, _, V), Lista),
    sum_list(Lista, Soma),
    length(Lista, Qtd),
    MediaVotos is Soma / Qtd.

medias_por_temporada(Temporada, Nota, Votos) :-
    media_nota_temporada(Temporada, Nota),
    media_votos_temporada(Temporada, Votos).

soma_votos_por_diretor(Diretor, Soma) :-
    diretor(Diretor),
    findall(V, episodio(_, _, _, _, _, Diretor, _, V), Lista),
    sum_list(Lista, Soma).

ordenando_mais_votados(Votos) :-
    setof((V - D), soma_votos_por_diretor(D, V), ListaVotos),
    reverse(ListaVotos, Votos).

soma_diferencas([], _, 0).

soma_diferencas([Head|Tail], Media, Soma) :-
    Dif is (Head - Media)^2,
    soma_diferencas(Tail, Media, SomaResto),
    Soma is Dif + SomaResto.

variancia(Lista, Media, Variancia) :-
    soma_diferencas(Lista, Media, Soma),
    length(Lista, Qtd),
    Variancia is Soma / Qtd.

variancia_temporada(Temporada, V) :-
    temporada(Temporada),
    findall(N, episodio(_, Temporada, _, _, _, _, N, _), Lista),
    media_nota_temporada(Temporada, Media),
    variancia(Lista, Media, V).

### query: ordenando_medias_anos(MelhoresAnos).
### query: ordenando_mais_votados(Votos).
### query: setof((T - N - V), medias_por_temporada(T, N, V), Lista).
### query: principal_diretor(Diretor).
### query: setof(T, variancia_temporada(T, Variancia), Lista).