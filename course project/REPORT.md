# Отчет по курсовому проекту
## по курсу "Логическое программирование"

### студент: <Меджидли Махмуд>

## Результат проверки

Вариант задания:

 - [x] стандартный, без NLP (на 3)
 - [ ] стандартный, с NLP (на 3-4)
 - [ ] продвинутый (на 3-5)
 
| Преподаватель     | Дата         |  Оценка       |
|-------------------|--------------|---------------|
| Сошников Д.В. |              |               |
| Левинская М.А.|              |               |

> *Комментарии проверяющих (обратите внимание, что более подробные комментарии возможны непосредственно в репозитории по тексту программы)*

## Введение

В результате выполнения курсового проекта я хочу ещё лучше освоить язык программирования Prolog, научиться писать более сложные предикаты
и естественно-языковый интерфейс, то есть взаимодействие с пользователем, окончательно познать парадигму логического программирования. 
Также в данном курсовом проекте я буду использовать Python, который является моим первым языком программирования, поэтому очень приятно
использовать именно его.

## Задание

  1, 4 и 5 задания у всех одинаковые.

2) Преобразовать файл в формате GEDCOM в набор утверждений на языке Prolog с использованием предиката child(ребенок, родитель), 
   male(человек), female(человек).
3) Реализовать предикат проверки/поиска свекрови (матери мужа).

## Получение родословного дерева

Я получил родословное дерево в формате GEDCOM с помощью сайта MyHeritage.com. Выбрал последнюю английскую правящую династию Виндзоров, 
так как будет легче проверять правильность выполненной работы (английские монархи - люди известные). В дереве представлено 47 индивидов.

## Конвертация родословного дерева

Для парсинга файла с форматом GEDCOM я решил выбрать Python, потому что очень хорошо знаю этот язык, многие пишут парсеры на Python,
в Python есть модуль gedcom для работы с форматом GEDCOM, что существенно облегчает парсинг.
С помощью модуля gedcom получаем всех членов королевской семьи. Получаем имена индивидов с помощью метода get_name объекта element 
класса Parser. Я завернул это в функцию grab_name, чтобы дважды код не повторять (для родителей позже тоже надо имена брать).

```python
def grab_name(element):
    (first, last) = element.get_name()
    if last == '':
        return first
    else:
        return first + " " + last
```

Далее узнаем пол индивида с помощью метода get_gender и составляем предикаты male и female.

```python
gender = element.get_gender()
if gender == 'M':
    men.append("male(" + "'" + name + "'" + ').')
else:
    women.append("female(" + "'" + name + "'" + ').')
```

Если у индивида есть родители, то получаем их и формируем предикат child.

```python
 if element.is_child():
    for parent in gedcom_parser.get_parents(element, "ALL"):
       name_parent = grab_name(parent)
       children.append("child(" + "'" + name + "'" + ", " + "'" + name_parent + "'" + ").")
```

Записываем предикаты в файл data.pl.

## Предикат поиска родственника

По заданию я написал предикат нахождения свекрови (матери мужа).

`mother_in_law(Mother_in_law, Wife)`

Реализация:

```prolog
father(M, C) :- child(C, M), male(M).
mother(W, C) :- child(C, W), female(W).
have_child(W, M) :- child(C, W), father(M, C), !.
mother_in_law(B, A) :- female(A), have_child(A, Z), female(B), child(Z, B).
% with repetitions
mother_in_law2(B, A) :- female(A), child(C, A), child(C, M), male(M), mother(B, M).
```

Обе реализации mother_in_law имеют единый принцип: если A является женщиной и имеет детей с мужчиной, то он является её мужем 
(в нашей модели так, в жизни не всегда). Далее просто находим мать мужа. Она и является искомой свекровью. 
Отличия реализаций: в реализации без повторов как только мы находим хотя бы одного ребёнка, то возвращаем мужа из have_child.
Во второй реализации для каждого ребёнка определяется отец (муж A), поэтому и возникают повторы.

Пример работы:
```prolog
?- mother_in_law(Mother_in_law, Wife).
Mother_in_law = 'Diana, Princess of Wales',
Wife = 'Catherine, Duchess of Cambridge' ;
Mother_in_law = 'Elizabeth II',
Wife = 'Diana, Princess of Wales' ;
Mother_in_law = 'Princess Anne',
Wife = 'Autumn Phillips' ;
Mother_in_law = 'Diana, Princess of Wales',
Wife = 'Meghan' ;
Mother_in_law = 'Elizabeth II',
Wife = 'Sarah, Duchess of York' ;
Mother_in_law = 'Elizabeth II',
Wife = 'Sophie, Countess of Wessex' ;
Mother_in_law = 'Mary of Teck',
Wife = 'Elizabeth Bowes-Lyon' ;
Mother_in_law = 'Mary of Teck',
Wife = 'Marina' ;
Mother_in_law = 'Mary of Teck',
Wife = 'Alice Montague' ;
false.
```

## Определение степени родства

Сначала определим предикаты для определения родства индивидов. Несложно понять, что будет достаточно 6 отношений родства: father,
mother, sister, brother, son, daughter, так как, имея эти отношения, мы сможем сделать move во все стороны от любого индивида.
Предикаты жена, муж следуют из того, что если индивид - A отец сына индивида B (ниже написано, как работает программа), следовательно, 
А - муж B.

```prolog
common_father(A, B) :- child(A, F), child(B, F), male(F), A \= B.
son(C, P) :- child(C, P), male(C).
daughter(C, P) :- child(C, P), female(C).
brother(A, B) :- common_father(A, B), male(A).
sister(A, B) :- common_father(A, B), female(A).

relation('father', M, C) :- father(M, C).
relation('mother', F, C) :- mother(F, C).
relation('son', C, P) :- son(C, P).
relation('daughter', C, P) :- daughter(C, P).
relation('brother', A, B) :- brother(A, B).
relation('sister', A, B) :- sister(A, B).

move(A, B) :- child(A, B).
move(A, B) :- child(B, A).
move(A, B) :- sister(A, B).
move(A, B) :- brother(A, B).
``` 

Предикат common_father помогает избегать повторы для предикатов sister и brother.

Чтобы определить степень родства двух произвольных индивидуумов в дереве, я решил воспользоваться поиском с итерационным заглублением.
Если нашлась связь между людьми, то мы, выходя из рекурсии, получаем список отношений между людьми, которые были на пути. Если же связь 
не нашлась, то мы делаем следующий шаг, и рекурсивно ищем относительно нового человека. 

```prolog
search_id(Path, A, B, N) :- N = 1, relation(Type, A, B), Path = [Type].
search_id(Path, A, B, N) :- N > 1, move(A, C), N1 is N - 1, search_id(Res, C, B, N1), relation(Type, A, C), append([Type], Res, Path).
``` 

Далее рассмотрим 2 вида запросов. Чтобы найти степень родства, нужно просто выполнить поиск с итерационным заглублением и вывести 
результат в нужном формате. А если нужно по степени родства определить индивидов, тогда форматируем её в список и ищем двух разных
людей, между которыми расстояние равно длине списка.

```prolog
:- op(200, xfy, of).

format(A of B, [A|C]) :- format(B, C).
format(A, [A]).

for(1).
for(M):- for(N), (N < 12 -> M is N+1; !, fail).

relative(Res, A, B) :- var(Res), for(N), N < 12, search_id(Path, A, B, N), B \= A, format(Res, Path).
relative(Res, A, B) :- nonvar(Res), format(Res, Path), length(Path, N), search_id(Path, A, B, N), B \= A.
``` 

Предикат for нужен, чтобы увеличивать N на единицу. Ограничением на N является 12, так как в родословном дереве представлено 6 
поколений. Предикаты op и format нужны для того, что получить путь в нужном формате. 

Пример работы:

```prolog
?- relative(Rel, 'George VI', 'George V').
Rel = son ;
Rel = brother of son ;
Rel = brother of son ;
Rel = brother of daughter ;
Rel = brother of son ;
Rel = brother of son ;
Rel = son of father of son

?- relative(father of father, X, Y).
X = 'Prince Charles, Prince of Wales',
Y = 'Prince George' ;
X = 'Prince Charles, Prince of Wales',
Y = 'Princess Charlotte' ;
X = 'Prince Charles, Prince of Wales',
Y = 'Prince Louis'
``` 

Читается, как "George VI является братом сына George V".

## Естественно-языковый интерфейс

Естественно-языковый интерфейс представлен 3 вопросами, которые являются достаточно гибкими:

A - человек

1. Who are parents of A? / Who is a sister/daughter.. of A?
2. What relationships/relations are between A and B?
3. How many sisters/brothers.. does A have?

Чтобы распарсить запрос, я разбиваю предложение на 2 части + знак вопроса. Первая часть - это сам вопрос, вторая - основная часть.
Во второй части (main) определяется парсинг конкретно тела вопроса. 

```prolog
parse(Type, Rel, A, B) --> question(Type), main(Type, Rel, A, B), [?].

% Who are parents of A?
question(who) --> [who], [are].

% Who is sister of A?
question(who) --> [who], [is].

% What relationships are between A and B?
question(relationships) --> [what], word, [are].

% How many sisters does A have?
question(how) --> [how], [many].

word --> [X], {member(X, [relationships, relations])}.

main(who, Rel, A, _) --> name(Rel), [of], name(A).
main(relationships, _, A, B) --> [between], name(A), [and], name(B).
main(how, Rel, A, _)  --> name(Rel), [does], name(A), [have].

% Coping with english articles
name(A) --> [B], [A], {member(B, [the, a])}, !.
name(A) --> [A].
``` 

--> означает DCG (definite clause grammar) нотацию, которая используется для парсинга предложения, то есть разбиения его на определенные 
группы слов. word помогает обрабатывать сразу два слова: relationships, relations. name позволяет понимать слова с артиклями.

Реализация ответов на вопросы и сам предикат ask. Хотел отметить, что если мы узнаем родителей индивида, тогда нужно задать две
переменные в предикате ask. Сделано это специально, так как пользователь должен понимать, что он хочет найти двух человек. 
 
```prolog
correct_rel(A, B) :- (A = sisters, B = sister); (A = brothers, B = brother); (A = sons, B = son); (A = daughters, B = daughter); B = A.

ans(who, Rel, A, B, Res) :- (Rel = parents, relative('father', Res, A), relative('mother', B, A)); correct_rel(Rel, Relation), relative(Relation, Res, A).
ans(relationships, _, A, B, Res) :- relative(Res, A, B).
ans(how, Rel, A, _, Res) :- Rel \= children, correct_rel(Rel, Relation), findall(B, relative(Relation, B, A), L), length(L, Res), !.
ans(how, _, A, _, Res) :- findall(B, child(B, A), L), length(L, Res).

ask(List, Res) :- parse(Type, Relation, A, B, List, []), ans(Type, Relation, A, B, Res).
ask(List, Res1, Res2) :- parse(Type, Relation, A, B, List, []), ans(Type, Relation, A, B, Res1), Res2 = B.
``` 

Примеры работы:

```prolog
?- ask([who, are, sisters, of, 'Savannah Phillips', ?], X).
X = 'Isla Phillips' ;
false.

?- ask([who, is, the, sister, of, 'Savannah Phillips', ?], X).
X = 'Isla Phillips' ;
false.

?- ask([who, are, the, parents, of, 'Savannah Phillips', ?], X, Y).
X = 'Peter Phillips',
Y = 'Autumn Phillips' ;
false.

?- ask([what, relations, are, between, 'George VI', and, 'Edward VIII', ?], X).
X = brother ;
X = son of father ;
X = son of mother ;
X = brother of brother


?- ask([how, many, sons, does, 'Prince Charles, Prince of Wales', have, ?], X).
X = 2.

?- ask([how, many, children, does, 'Prince William, Duke of Cambridge', have, ?], X).
X = 3.
``` 


## Выводы

Таким образом, данная работа научила меня многим вещам. Например, я научился работать с естественно-языковым интерфейсом на Prolog.
В ходе работы узнал про DCG нотацию, которая значительно упростила работу с предложениями. Ещё я повторил поиск в Prolog, так как
здесь нужно было использовать его, что безусловно укрепило мои знания. При реализации естественно-языкового интерфейса было интересно
просчитывать варианты развития событий, поведение пользователя. Также когда я понял как избегать повторы, это было непередаваемое
чувство удовлетворения. 
