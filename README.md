# Knowledge Engine - Friends Dataset

Um mecanismo de busca implementado com **Lógica de Primeira Ordem** usando **Prolog**. Este projeto constrói uma base de conhecimento a partir do dataset da série *Friends* e realiza consultas sofisticadas usando predicados e sentenças lógicas.

## Visão Geral do Projeto

**Objetivo:** Explorar o paradigma de programação lógica através de um Knowledge Engine que responde perguntas sobre episódios da série Friends utilizando inferência lógica.

**Dataset:** [Friends Series Dataset](https://www.kaggle.com/datasets/rezaghari/friends-series-dataset) do Kaggle

**Campos utilizados:**
- Episode Title (título do episódio)
- Season (temporada)
- Episode Number (número do episódio)
- Year of Production (ano de produção)
- Duration (duração)
- Director (diretor)
- Stars (nota/avaliação)
- Votes (número de votos)

## Estrutura do Projeto

```
MD-Project/
├── ETL.ipynb              # Script que transforma CSV em predicados Prolog
├── prolog/
│   ├── friends.pl         # Base de conhecimento (predicados gerados)
│   └── queries.pl         # Todas as sentenças e queries do projeto
├── pyproject.toml         # Configuração do projeto Python
└── README.md              # Este arquivo
```

## Como Funciona o ETL

O arquivo `ETL.ipynb` realiza os seguintes passos:

1. **Download do Dataset:** Baixa o dataset de Friends do Kaggle usando `kagglehub`
2. **Carregamento:** Lê o arquivo CSV com informações dos episódios
3. **Transformação:** Converte cada linha em um predicado Prolog formatado
4. **Limpeza:** Remove caracteres especiais e espaços dos textos
5. **Geração:** Escreve todos os predicados no arquivo `prolog/friends.pl`

### Formato do Predicado

```prolog
episodio(titulo, temporada, numero_ep, ano, duracao, diretor, nota, votos).
```

**Exemplo:**
```prolog
episodio(the_one_where_monica_gets_a_roommate, 1, 1, 1994, 24, james_burrows, 8.3, 4417).
```

## Como Rodar o Projeto

### Passo 1: Gerar a Base de Conhecimento

Se precisar regenerar a base de dados (opcional):

```bash
# Execute o notebook ETL
jupyter notebook ETL.ipynb
```

Isso gerará o arquivo `prolog/friends.pl` com todos os predicados.

### Passo 2: Executar as Queries no SWISH

1. Acesse [SWISH - SWI-Prolog Web IDE](https://swish.swi-prolog.org/)
2. Clique em **"Program"**
3. Na área **Program**, copie e cole o conteúdo de `prolog/friends.pl` e logo depois o conteúdo de `prolog/queries.pl` (que são nossas sentenças/regras)
5. As últimas 5 linhas de `prolog/queries.pl` tratam-se das queries que podem ser usadas para responder as perguntas. Organizei assim para testar com maior facilidade, mas é necessário tirar essas queries comentadas para não dar erro ao testar no SWISH!

### Passo 3: Executar as Queries

Execute cada query em uma célula de **Query** no SWISH:

# Queries

Aqui eu mostro as sentenças criadas necessárias para responder cada uma das perguntas em particular, e logo abaixo a query de deve ser utilizada.

## Quais foram os melhores anos de Friends por nota?

````
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
````    

### Query:
````
?- ordenando_medias_anos(MelhoresAnos).
````
## Qual diretor dirigiu mais episódios? 
````
diretor(Diretor) :-
    episodio(_, _, _, _, _, Diretor, _, _).

quantidade_ep_dirigidos(Diretor, Quantidade) :-
    diretor(Diretor),
    findall(E, episodio(E, _, _, _, _, Diretor, _, _), Lista),
    length(Lista, Quantidade).

principal_diretor(Diretor) :-
    setof((Q, D), quantidade_ep_dirigidos(D, Q), ListaDiretores),
    reverse(ListaDiretores, [(_, Diretor) | _]).
````

### Query:
````
?- principal_diretor(Diretor)
````
## Qual a média de nota e votos por temporada?

````
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
````

### Query:
````
?- setof((T - N - V), medias_por_temporada(T, N, V), Lista).
````
## Qual a ordem dos diretores que tiveram o maior número de votos?

````
diretor(Diretor) :-
    episodio(_, _, _, _, _, Diretor, _, _).

soma_votos_por_diretor(Diretor, Soma) :-
    diretor(Diretor),
    findall(V, episodio(_, _, _, _, _, Diretor, _, V), Lista),
    sum_list(Lista, Soma).

ordenando_mais_votados(Votos) :-
    setof((V - D), soma_votos_por_diretor(D, V), ListaVotos),
    reverse(ListaVotos, Votos).
````    

### Query:
````
?- ordenando_mais_votados(Votos)
````
## Qual temporada tem a maior consistência de notas (menor variância)?

````
temporada(Temporada) :-
    episodio(_, Temporada, _, _, _, _, _, _).

media_nota_temporada(Temporada, MediaNota) :-
    temporada(Temporada),
    findall(N, episodio(_, Temporada, _, _, _, _, N, _), Lista),
    sum_list(Lista, Soma),
    length(Lista, Qtd),
    MediaNota is Soma / Qtd.

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
````

### Query:
````
?- setof(T, variancia_temporada(T, Variancia), Lista).
````

## Conceitos de Prolog Utilizados

- **Predicados:** Declarações básicas da base de conhecimento
- **Sentenças:** Definidas com `:-` para criar lógica complexa
- **Unificação:** Pattern matching para comparar e associar valores
- **Backtracking:** Busca automática por todas as soluções possíveis
- **findall/3:** Coleta todos os resultados que satisfazem uma condição
- **setof/3:** Ordena e remove duplicatas dos resultados
- **Aritmética:** Operações com `is` para cálculos

## Análise das Queries

1. **Query 1:** Identifica os melhores anos da série calculando a média de notas por ano
2. **Query 2:** Encontra o diretor mais prolífico (que dirigiu mais episódios)
3. **Query 3:** Calcula estatísticas por temporada (média de notas e votos)
4. **Query 4:** Ranking de diretores pelos votos totais recebidos
5. **Query 5:** Avalia a consistência de qualidade por temporada usando variância

## Requisitos Atendidos

- Dataset individual do Kaggle (Friends)
- ETL em Python para geração da base Prolog
- Base de conhecimento com múltiplos predicados
- 5 queries sofisticadas com sentenças avançadas
- Uso de agregações, ordenação e comparações
- README com instruções completas

## Notas Importantes

- Todos os predicados e constantes em Prolog estão em minúsculas
- Espaços foram substituídos por underscores (`_`)
- Acentos e caracteres especiais foram removidos
- As queries utilizam padrões sofisticados de agregação e análise
- As queries usam "-" para melhor visualização dos rankings para separar as informações, em vez de "," que é o padrão.