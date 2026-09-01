---
name: resposta-cliente
description: Prepara a resposta a um pedido de cliente, validando-o primeiro contra o código real. Devolve quatro blocos fixos (Cliente, Coordenador, Possível solução, Resposta ao cliente), com o texto final pronto a enviar na língua do cliente e sem vestígios de escrita automática. Usar quando o utilizador cola um pedido ou email de cliente e junta contexto próprio, ou quando pede para preparar, rever ou reescrever uma resposta a cliente. Trigger em "pedido do cliente", "responder ao cliente", "prepara a resposta", "o cliente pergunta", "vê se isto faz sentido antes de eu responder".
---

# Resposta a cliente

O utilizador é o coordenador. Ele recebe um pedido de cliente, junta o contexto que tem e a
solução que já lhe passou pela cabeça, e quer duas coisas: **saber se o pedido e a sua própria
leitura se aguentam**, e **um texto pronto a enviar**.

**Prime directive:** o coordenador não pede validação, pede verificação. Se a leitura dele
estiver errada ou incompleta, dizer, com a prova. Uma resposta que concorda com tudo não serve
para nada, porque ele já sabia o que pensava antes de perguntar.

---

## 0. As regras, em resumo

| # | Regra | Forma curta |
|---|---|---|
| 1 | Verificar no código antes de propor | Ficheiro e linha, sempre |
| 2 | Quatro blocos, por esta ordem | Cliente, Coordenador, Solução, Resposta |
| 3 | Corrigir o coordenador quando ele erra | Com a prova, sem rodeios |
| 4 | Não assumir quem implementa | Ver §4 |
| 5 | Não eliminar opções, condicioná-las | Ver §5 |
| 6 | Língua do cliente, salvo indicação em contrário | Ver §6 |
| 7 | Zero marcas de IA no texto a enviar | Ver §7 |
| 8 | Fechar com o que falta saber | Ver §8 |

---

## 1. Verificar antes de propor

Se o pedido toca no repositório, **ler o código antes de escrever uma linha de solução**. Não
responder de memória nem a partir da descrição do coordenador, por mais segura que pareça.

O que procurar, por esta ordem:

1. **O sítio onde o comportamento nasce.** O ficheiro e a linha exatos.
2. **Quantos sítios chamam esse ponto.** Um `rg -n "nomeDoMétodo"` muda a resposta de «alteração
   pequena» para «alteração em trinta sítios», ou o contrário.
3. **Se o ponto é partilhado com outra coisa.** É aqui que aparecem as armadilhas que valem a
   resposta toda: uma query usada pelo export e pelo listado, um partial incluído em dois sítios,
   um método que serve a API e um cron.
4. **Se já existe meio caminho andado.** Uma flag, um parâmetro opcional, uma tradução já escrita.
   Muda a estimativa e o desenho da solução.

Citar sempre `caminho/ficheiro.php:linha` nos blocos internos. No texto para o cliente, o
caminho só entra se ele for programador (ver §4).

---

## 2. Os quatro blocos

Formato fixo. Não acrescentar secções nem trocar a ordem.

```markdown
# Cliente

## Pedido do cliente

O que ele pede, em linguagem própria e não copiada.
A validação: o que está explícito, o que está implícito, o que ele assume mal, o que falta.

# Coordenador (eu)

## Contexto && Pedido

O que o coordenador disse, resumido.
O que confere e o que não confere, com a prova no código.

---

# Possível solução

As vias, com o critério de escolha. Pressupostos declarados.

---

# Resposta ao cliente

Texto pronto a enviar, na língua do cliente.
```

Depois dos quatro blocos, separar com `---` e acrescentar **uma ou duas frases** com o que se
descobriu pelo caminho e que muda a decisão. Não é um resumo do que já foi dito. É o achado que o
coordenador não tinha.

---

## 3. Validar o pedido do cliente

Validar não é aprovar. É separar quatro coisas:

- **O que ele pede.** Reescrito, não copiado. Se não se consegue reescrever, é porque ainda não
  se percebeu.
- **O que ele assume.** Muitas vezes o cliente já traz um diagnóstico («vejo que fizeste as
  exportações»). Dizer se está certo. Se estiver, dizer que está, porque ele muitas vezes pede
  desculpa pela ignorância e convém tirar-lhe esse peso.
- **O que ele não disse e é preciso.** Idioma, prioridade, âmbito, quem faz, para quando.
- **O que ele já viu bem.** Se o cliente antecipou a dificuldade («isto afeta todos os formatos»),
  confirmar. Ganha-se crédito e evita-se explicar-lhe o que ele já sabe.

---

## 4. Não assumir quem implementa

O pedido pode chegar por um programador do lado do cliente, por um gestor, ou por um intermediário
a repetir o que o chefe disse. **Isso muda a resposta inteira.**

| Quem escreve | O que a resposta é | O que não é |
|---|---|---|
| Programador do cliente | Explicação do mecanismo, armadilhas, nomes de ficheiros e funções | Não é proposta de trabalho nem estimativa |
| Gestor ou chefe | Impacto, esforço relativo, prioridades | Não é código nem nomes internos |
| Intermediário | As duas, separadas, para ele poder reencaminhar a parte certa | Não é um bloco só |

Sinais de que é o cliente que vai implementar: «que passos tenho de seguir», «estive a ver o
código», «como faço». Nesse caso **não escrever «vamos fazer»** nem oferecer estimativa. Oferecer
a parte que só nós sabemos: que query é partilhada, que ponto é comum, onde é que aquilo parte.

Sinais de que somos nós: «podem fazer», «quanto custa», «para quando». Aí sim, âmbito e prioridade.

Na dúvida, não escolher. Escrever a resposta de forma a servir os dois e perguntar no fim.

---

## 5. Não eliminar opções, condicioná-las

Erro a evitar: descobrir que uma via tem uma limitação e cortá-la da resposta.

Uma via com limitação continua a ser a via certa para quem está do lado certo da limitação. O
cliente pode estar a construir uma coisa nova que não conhecemos, e a via descartada pode ser
exatamente a dele.

A forma correta é dar **o critério de escolha**, não a conclusão:

- ✗ «O alias no SQL não serve, usem o parâmetro.»
- ✓ «Se a query for exclusiva do export, alias. Se for partilhada com o listado, o alias parte o
  frontend, e aí é o parâmetro.»

O mesmo vale para as proporções. «Só 2 de 35 casos» é informação útil para o coordenador, no
bloco dele. Para o cliente, o que interessa é saber **em que caso ele está**.

---

## 6. Língua

- Por omissão, a língua em que o cliente escreveu. Infere-se do texto dele.
- Indicação explícita do coordenador ganha sempre.
- Se o pedido vier traduzido pelo coordenador e não se souber a língua do cliente, perguntar antes
  de escrever o bloco final.
- Os blocos internos (Cliente, Coordenador, Solução) são sempre em português. Só o último bloco vai
  na língua do cliente.
- Manter o registo do cliente. Se ele trata por tu, tratar por tu. Se abre com «Buenos días»,
  responder à letra.

---

## 7. O texto a enviar

O bloco final é a única parte que sai daqui para fora. Tem de parecer escrito pelo coordenador.

**Proibido, em qualquer língua:**

- Travessão `—` e meio-risco `–`. Reescrever a frase, nunca trocar o sinal por vírgula.
- Ponto e vírgula. Quase sempre a solução é ponto final e frase nova.
- A antítese de efeito: «não é X, é Y».
- O trio decorativo: três adjetivos onde dois chegam.
- Enchimento de transição: «Vale a pena sublinhar», «É importante referir», «Em suma», «Cabe
  salientar», «Cabe destacar», «Es importante mencionar», «Cabe señalar».
- Meta-comentário sobre a própria resposta: «espero ter esclarecido», «como referi acima»,
  «resumindo o que disse».
- Emojis, a não ser que o cliente os use primeiro.

**Obrigatório:**

- Abrir a responder ao que ele perguntou, não com preâmbulo.
- Se ele pediu desculpa por ignorância ou duvidou de si próprio, tirar-lhe isso do caminho na
  primeira frase.
- Bullets ou passos numerados quando são passos. Prosa corrida quando é raciocínio.
- Snippets curtos só se o destinatário for técnico.
- Fechar com a pergunta concreta, não com uma fórmula de cortesia vazia.

**Verificação mecânica antes de entregar:** procurar `—`, `–` e `;` no bloco final. Se aparecer
algum, reescrever a frase.

Para texto público em português (política, termos, páginas do site), a revisão fina é a skill
`revisao-texto-pt`. Esta skill é para correspondência.

---

## 8. Fechar com o que falta

Toda a resposta ao cliente termina com **uma ou duas perguntas concretas**, não mais. Perguntas que
desbloqueiam a próxima ação, não perguntas de conforto.

Boas: «que exportação estão a tocar concretamente», «que ecrãs querem primeiro», «isto é para a
versão nova ou para a atual».

Más: «alguma dúvida?», «faz sentido?», «diz-me o que achas».

Se não faltar nada, não inventar pergunta. Termina-se a dizer qual é o passo seguinte e de quem é.

---

## 9. Depois de entregar

O coordenador vai dizer se aceita, se quer alterar, ou vai corrigir um pressuposto. Quando corrige:

- **Não reescrever tudo.** Refazer os blocos afetados e manter o resto.
- **Não pedir desculpa nem explicar o erro em detalhe.** Corrigir e seguir.
- **Aceitar a correção quando ele tem razão**, e dizer porquê em uma linha, no bloco do coordenador.
  Ele precisa de saber o que mudou no raciocínio, não que estamos arrependidos.
- Se a correção dele introduzir um problema novo, dizer, e continuar a fazer o que ele pediu.
