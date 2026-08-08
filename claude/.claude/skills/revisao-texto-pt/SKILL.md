---
name: revisao-texto-pt
description: Revisão de copy em Português de Portugal para texto público. Corta os vestígios de escrita automática (travessão, ponto e vírgula, aspas retas, antíteses, meta-comentário auto-elogioso), simplifica frases complicadas, elimina ideias repetidas e corrige erros de PT-PT (brasileirismos, pleonasmos, concordância, regência), sem alterar o sentido legal, valores, prazos ou referências normativas. Usar sempre que for pedido para rever, corrigir, limpar, reescrever ou despiorar texto em português, seja política de privacidade, termos e condições, cookies, emails, páginas do site, READMEs ou mensagens de UI. Trigger em "revê este texto", "corrige a escrita", "parece escrito por IA", "tira os travessões", "português de Portugal", "copy", "rever texto público".
---

# Revisão de texto em Português de Portugal

O objetivo é um texto que **pareça escrito por uma pessoa** e que **não perca uma vírgula do
sentido legal ou factual**. Não é uma reescrita criativa: é uma revisão. Quem já conhecia o
documento tem de o reconhecer depois de revisto.

**Prime directive:** na dúvida entre elegância e exatidão, ganha a exatidão. Um período mais seco
mas correto vale mais do que uma frase bonita que altera uma obrigação.

---

## 0. As regras, em resumo

| # | Regra | Forma curta |
|---|---|---|
| 1 | Zero travessões (`—`, `–`) e zero pontos e vírgulas | Reescrever, nunca trocar o sinal |
| 2 | Aspas angulares `«»`, não retas `""` | Convenção portuguesa |
| 3 | Cortar o auto-elogio e o meta-comentário | O texto não comenta o texto |
| 4 | Uma ideia, um sítio | Repetida é cortada, não parafraseada |
| 5 | Frase longa parte-se, não se enfeita | Duas frases simples > uma com três encaixes |
| 6 | Português europeu, sem brasileirismos | E sem gerúndio de ação em curso |
| 7 | Números, prazos, artigos e nomes não se tocam | Ver §4 |
| 8 | Verificar por `grep` no fim, sempre | Ver §7 |

---

## 1. Sinais proibidos (mecânico, verificável)

**Banidos do corpo do texto:**

- Travessão `—` e meio-risco `–`, em qualquer função.
- Ponto e vírgula `;`.
- Aspas retas `"` e `'` a fazer de aspas.
- Reticências em `...` quando são só hesitação. Se a frase hesita, corta-se a hesitação.

**Exceções, e são só estas:** blocos de código, `código inline`, URLs, IBANs, identificadores
técnicos, e citações literais de terceiros onde o sinal faz parte da fonte. Se um `;` aparece num
snippet de CSS ou PHP, fica.

Um nome oficial que contenha travessão **não é exceção**: resolve-se com parênteses (ver §2).

---

## 2. Como matar o travessão sem estragar a frase

O erro a evitar é a troca mecânica por vírgula ou por dois pontos. Isso deixa a frase com o mesmo
ritmo estranho e só esconde a marca. **Cada travessão obriga a reescrever a oração.** Padrões, com
casos reais:

| Função do travessão | Antes | Depois |
|---|---|---|
| Aposto enumerativo | `o custo da secção — espaço, material, treinador — mantém-se` | `o custo da secção com espaço, material e treinador mantém-se` |
| Inciso condicional | `o pagamento e — tratando-se de menor — a autorização` | `o pagamento e, tratando-se de menor, a autorização` |
| Glosa explicativa | `O detalhe — que cookies, para quê, e porque não há banner — está na...` | `O detalhe, que cookies são, para que servem e porque não lhe mostramos um banner, está na...` |
| Ressalva encaixada | `Não desfaz o que foi transmitido antes dela — isso não está na nossa mão —, e não afeta` | `Não desfaz o que foi transmitido antes dela, o que já não está na nossa mão, e não afeta` |
| Nome de entidade | `N.G.D. — Novasemente Grupo Desportivo` | `Novasemente Grupo Desportivo (N.G.D.)` na 1.ª menção, `N.G.D.` depois |
| Morada | `Av. D. Carlos I, 134 — 1.º` | `Av. D. Carlos I, 134, 1.º` |
| Separador de horário | `3x por semana — Segundas e Sextas: 18:30 às 19:30` | `3 vezes por semana, às segundas e sextas-feiras, das 18:30 às 19:30` |

Para o ponto e vírgula, o mesmo princípio: quase sempre a solução é **ponto final e frase nova**.

- `não é uma exigência nossa; não usamos esses dados` → duas frases.
- Bullets de lista terminados em `;` → terminar em `.`
- `não protege ninguém: treina as pessoas a carregar em «aceitar»` → `não protege ninguém e só
  habitua as pessoas a carregar em «aceitar»`

---

## 3. Delusões: o que cortar sem dó

Texto gerado tende a elogiar-se a si próprio e a explicar as suas próprias intenções. É o vestígio
mais forte de IA, mais do que a pontuação. **O documento diz o que é, não diz que é honesto.**

Caçar e cortar:

**a) A antítese de efeito.** `X não é Y, é Z.`
- ✗ `um contrato que só se percebe com ajuda não é um contrato, é uma armadilha`
- ✓ `estão escritos de propósito em linguagem corrente, para que se percebam sem ajuda de ninguém`
- ✗ `a disciplina em sala não é etiqueta, é segurança`
- ✓ `a disciplina em sala é uma questão de segurança`

**b) O elogio da própria honestidade.** `É a única forma honesta de...`, `seria mentir`, `não
fingimos que`, `com franqueza`, `e não é decorativa`, `dizemos isto porque é verdade`.
- ✗ `Prometer apagamento instantâneo seria mentir, e uma política que promete o que o sistema não
  faz é pior do que não ter política.` → **cortar inteiro.** O parágrafo anterior já disse o facto.

**c) O comentário sobre a escolha de palavras.**
- ✗ `dizemos "não pode ser excluído" em vez de "não acontece" porque a segunda não a poderíamos
  demonstrar`
- ✓ afirmar diretamente o facto: `Do funcionamento normal do serviço não decorre qualquer
  transferência de dados para fora do EEE.`

**d) O preâmbulo sobre a legibilidade do documento.**
- ✗ `Está escrita para ser lida.` / `É uma lista curta, e é curta porque não há nada a esconder.`
- ✓ `É uma lista curta.` ou nada.

**e) Enchimento de transição:** `Vale a pena sublinhar que`, `É importante referir que`, `Em suma`,
`Em última análise`, `Relativamente a`, `No que diz respeito a`, `Cabe salientar`. Quase sempre a
frase funciona melhor sem eles.

**f) O trio decorativo.** Três adjetivos ou três sintagmas quando dois bastam (`clara, honesta e
transparente`). Cortar o que não acrescenta.

**Nota de calibração:** uma frase com personalidade não é uma delusão. `O site tem de correr em
algum lado` é boa escrita e fica. O que sai é a frase que se admira a si própria.

---

## 4. O que nunca se toca

Antes de mexer, marcar mentalmente como intocável:

- **Valores, prazos, datas, percentagens, horários, IBAN, NIF, NIPC, números de telefone.**
- **Referências normativas** e a sua forma: `Art. 6.º, n.º 1, al. b)`, `Lei n.º 58/2019`,
  `artigo 26.º, n.º 3`. Não uniformizar `Art.` para `artigo` se o documento alterna por hábito
  próprio, e nunca alterar o número.
- **Âncoras de secção** `{#slug}`, ids, nomes de rotas, links internos.
- **A força da obrigação.** `deve` ≠ `pode` ≠ `tem de`. `não é devolvido` ≠ `pode não ser
  devolvido`. Não suavizar nem endurecer.
- **O negrito com valor jurídico.** Onde o negrito marca a regra vinculativa, mantém-se.
- **Nomes de entidades, cargos e pessoas.**

Se a correção de estilo obrigar a mexer num destes, **parar e perguntar**.

---

## 5. Erros de PT-PT a procurar sempre

**Regência e semântica traiçoeiras** (o erro que passa despercebido porque a frase parece bem):

| Errado | Certo | Porquê |
|---|---|---|
| `ligar para uma página` | `criar ligações para uma página` | `ligar para` é telefonar |
| `provas para que confirmou presença` | `provas em que confirmou presença` | regência de `comparecer em` |
| `via MB Way` / `via transferência` | `por MB Way` / `por transferência` | `via` é caminho, não meio |
| `de forma a` | `para` | perífrase inútil |

**Pleonasmos e redundância** (marca clássica de texto gerado ou de texto administrativo velho):
- ✗ `possibilita as seguintes possibilidades de pagamento` → ✓ `há duas formas de pagamento`
- ✗ `a possibilidade de frequentar todos os treinos` → ✓ `dá direito a todos os treinos`
- ✗ `Relativamente aos pagamentos, ...` a abrir uma secção chamada «Pagamentos»

**Concordância**, sobretudo quando o sujeito está longe do verbo:
- ✗ `Os custos com a participação em competições não está incluído`
- ✓ `A participação em competições tem custos à parte`

**Brasileirismos e gerundismo:**

| Não | Sim |
|---|---|
| está sendo tratado | está a ser tratado |
| arquivo, tela, usuário, celular, time, e-mail (com hífen em contexto PT informal) | ficheiro, ecrã, utilizador, telemóvel, equipa, email |
| acessar, deletar, printar | aceder, apagar, imprimir |
| planejamento, registrar | planeamento, registar |
| você | tratamento na 3.ª pessoa (`si`, `pode`, `o seu`) |

**Ortografia AO90 sem hipercorreção.** Em PT-PT mantêm-se as consoantes que se pronunciam:
`contacto`, `facto`, `contactar`, `caracterizar`. Caem as mudas: `direção`, `atividade`, `adoção`,
`receção`, `deteta`, `eletrónico`, `respetivo`. Erro comum é cortar a mais (`contato`, `fato`).

**Maiúsculas.** Dias da semana e meses em minúscula (`às segundas`, `em agosto`). Cargos em
minúscula (`o diretor da sala`). Só nomes próprios e denominações oficiais levam maiúscula.

**Tratamento.** Escolher um e manter: normalmente `você` implícito na 3.ª pessoa (`pode`, `escreva`,
`o seu`) e `nós` para a entidade. Nunca alternar entre `tu` e `si` no mesmo documento.

---

## 6. Frase complicada e ideia repetida

**Partir, não enfeitar.** Se a frase tem mais de dois encaixes, ou se é preciso reler para achar o
sujeito, parte-se em duas. Alvo prático: uma frase que passe de 40 palavras é candidata a corte.

**Uma ideia, um sítio.** Se a mesma garantia aparece duas vezes em secções diferentes, fica na
secção onde é operativa e sai da outra, ou fica uma remissão (`Ver [Fotografias e vídeos](#imagem)`).
Não parafrasear a mesma ideia com outras palavras: isso é a repetição a disfarçar-se.

**Manter a ordem das secções e o número de parágrafos sempre que possível.** Uma revisão que
reorganiza o documento deixa de ser verificável pelo autor. Se uma secção tiver mesmo de mudar de
sítio, dizer no relatório.

---

## 7. Antes e depois de editar (ficheiros num repositório)

Quando o texto vive num projeto e não numa conversa, há passos que não se podem saltar.

**Antes:**

1. **Procurar quem depende do texto.** Âncoras e links internos:
   ```bash
   grep -rn "#slug-da-ancora" --include="*.php" --include="*.md" .
   ```
2. **Procurar partials incluídos.** Um `@include` ou `{{> }}` significa que o mesmo texto serve
   outro sítio (tipicamente emails). Mexer nele muda os dois. Verificar antes, e avisar o utilizador.
3. **Procurar testes que fixem strings do texto.**
   ```bash
   grep -rn "trecho literal do texto" tests/
   ```
4. **Perceber se o documento é versionado por hash.** Em documentos legais com consentimento
   registado, mudar uma vírgula pode gerar uma versão nova e invalidar consentimentos. Isto **tem
   de ser dito ao utilizador antes do deploy**, mesmo que a alteração seja puramente editorial.

**Armadilhas de Markdown encontradas na prática:**

- `*** Texto` no início de linha **não é** marcador de nota de rodapé. Em CommonMark abre ênfase
  que nunca fecha e os asteriscos saem impressos. Usar parágrafo normal.
- Listas com ` 1)` indentadas com espaço à frente e um `Ou` solto entre os itens não são lista
  nenhuma. Usar lista ordenada real e passar a alternativa para a frase introdutória.
- Cabeçalhos com `{#ancora}` exigem a extensão de atributos. Não inventar âncoras novas.
- `«»` renderizam bem em HTML e em email; não precisam de escape.

**Depois, obrigatório:**

```bash
grep -nE '—|–|;|"|\bvocê\b|\bacessar\b|\barquivo\b|\busuário\b|\btela\b|\bestá [a-zç]+ndo\b' <ficheiros>
```

Saída vazia (exit 1) é o resultado esperado. Qualquer linha que apareça é um caso a justificar,
não a ignorar.

Depois disso, correr os testes do projeto. Se falhar algum, verificar se falha também com a árvore
limpa (`git stash`) antes de o atribuir à revisão. Testes instáveis existem e não se assumem como
regressões nossas.

---

## 8. Como reportar no fim

Curto, agrupado por tipo, com o antes e o depois dos casos que interessam. Nunca uma lista
exaustiva de cada vírgula.

1. **Pontuação e marcas de escrita automática.** Confirmar zero ocorrências e mostrar as
   reescritas não óbvias (nomes de entidades, moradas, incisos).
2. **Retórica removida.** Citar as frases cortadas. É a parte que o autor mais quer ver, porque é
   onde a revisão é discutível.
3. **Correções de língua.** Os erros a sério (regência, concordância, brasileirismos), não as
   preferências.
4. **Fora do âmbito.** O que se encontrou e não se tocou, e porquê.
5. **Consequências.** Versionamento, consentimentos, testes, ficheiros partilhados.

O que **não** vai no relatório: elogios ao resultado, contagens de palavras poupadas, ou a
explicação de que o texto agora está mais claro. Isso é a delusão a reaparecer no relatório depois
de ter sido cortada do documento.
