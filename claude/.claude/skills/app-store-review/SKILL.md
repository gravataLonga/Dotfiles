---
name: app-store-review
description: Validar uma app contra as App Review Guidelines da Apple antes de a submeter. Levanta os factos da app a partir do código (modelo de negócio, contas, permissões, SDKs, rede, extensões), corta as regras que não se aplicam, verifica uma a uma as que sobram com evidência no repositório, e devolve um relatório com o que está conforme, o que é risco de chumbo e o que ainda falta preencher no App Store Connect. Usar em "vou submeter a app", "isto passa na review da Apple?", "prepara a submissão para a App Store", "porque é que a Apple chumbou isto", "/app-store-review".
disable-model-invocation: true
---

# Revisão prévia à App Store

Fonte canónica: <https://developer.apple.com/app-store/review/guidelines/>
O mapa abaixo foi conferido contra a página a 22 de agosto de 2026.

O documento da Apple é vivo e a numeração muda sem aviso. Se uma regra for **decisiva** para o
veredicto, ou se citares uma que não esteja neste ficheiro, vai buscar a página antes de a citar.
Para o resto, este mapa chega.

## Regras deste trabalho

1. **Nada é dado como conforme sem prova.** Cada linha do relatório aponta para um ficheiro e linha,
   para um campo concreto do App Store Connect, ou fica marcada como
   `não verificável a partir do código`.
2. **Não inventar números de guideline.** Citar só os que estão aqui ou os que foram lidos na página.
   Um número errado num relatório de conformidade é pior do que não haver número nenhum.
3. **Três estados, não dois:** conforme, risco, falha. *Risco* é o que passa hoje mas chumba se o
   revisor abrir a gaveta errada. É a categoria mais útil das três e a que nunca deve ficar vazia
   por preguiça.
4. **O que não se aplica escreve-se na mesma**, com uma linha a dizer porquê. Um relatório que só
   mostra o que corre bem não serve para decidir se se carrega no botão.
5. **Não prometer aprovação.** A review é humana e discricionária, e a própria Apple o escreve
   ("I'll know it when I see it"). O relatório diz o que está em ordem e onde é que a app está
   exposta. Mais do que isso é invenção.

---

## Passo 1: levantar os factos da app

Responder a isto **a partir do código**. Só perguntar ao utilizador o que não existe em lado nenhum
no repositório, e perguntar tudo de uma vez no fim do levantamento, não a conta-gotas.

| # | Facto a apurar | Abre a porta a |
|---|---|---|
| 1 | Plataformas e alvos: iOS, iPadOS, macOS, tvOS, watchOS, visionOS; famílias de dispositivo | 2.4.1, 2.4.3, 2.4.5 |
| 2 | Modelo de preço: grátis, paga, IAP, subscrições, pagamentos fora da app | secção 3 inteira |
| 3 | Contas: há login? é próprio ou de terceiros (Google, Facebook, Apple)? cria-se conta na app? | 4.8, 5.1.1(v) |
| 4 | Conteúdo gerado por utilizadores, chat, perfis públicos, comentários | 1.2, 1.2.1 |
| 5 | Dados pessoais tratados, e **de quem**: do utilizador ou de terceiros (nomes de atletas, alunos, doentes) | 5.1.1, 5.1.2 |
| 6 | Permissões pedidas e o texto das *usage descriptions* | 5.1.1(ii), 5.1.1(iii) |
| 7 | SDKs de terceiros: analytics, publicidade, crash reporting, tracking/IDFA | 1.2, 5.1.1(i), 5.1.2(i) |
| 8 | Backend: URLs, autenticação, e se fica **vivo e acessível** durante a review | 2.1, 2.5.5 |
| 9 | Background modes, notificações push, widgets, extensões, App Clips | 2.5.4, 2.5.16, 4.4, 4.5.4 |
| 10 | WebView, conteúdo remoto, atualizações OTA de código (EAS Update, CodePush) | 2.5.2, 2.5.6, 4.2.2 |
| 11 | Idade-alvo e se entra na categoria Kids | 1.3, 2.3.6, 5.1.4 |
| 12 | Marcas e conteúdos de terceiros: nomes, logos, dados de federações, ligas, clubes | 5.2.1, 5.2.2 |
| 13 | Modo demo ou credenciais de teste para o revisor | 2.1(a) |
| 14 | Hardware ou material externo necessário para usar a app (QR, leitor, sensor) | 2.1(a), 4.2.3(i) |

### Onde procurar, por stack

- **Nativo:** `*/Info.plist`, `*.entitlements`, `project.pbxproj`, `Podfile.lock`, `Package.resolved`
- **Expo / React Native:** `app.json` ou `app.config.*`, `eas.json`, `ios/*/Info.plist`, `package.json`, `plugins/`
- **Flutter:** `pubspec.yaml`, `ios/Runner/Info.plist`, `ios/Runner/*.entitlements`
- **Capacitor:** `capacitor.config.*`, `ios/App/App/Info.plist`

### Buscas que valem sempre a pena

```sh
# permissões e o texto que as acompanha
grep -rn "UsageDescription" --include="*.plist" --include="*.json" --include="*.ts" .

# background modes, ATS aberto, tracking
grep -rn "UIBackgroundModes\|NSAppTransportSecurity\|NSAllowsArbitraryLoads" --include="*.plist" .
grep -rn "AppTrackingTransparency\|idfa\|advertisingIdentifier" -i .

# endpoints locais esquecidos e placeholders
grep -rniE "localhost|127\.0\.0\.1|ngrok|\.test/|lorem ipsum|TODO|FIXME|coming soon" --include="*.ts" --include="*.tsx" --include="*.swift" --include="*.dart" src app 2>/dev/null

# SDKs de terceiros declarados
cat package.json 2>/dev/null | grep -iE "analytics|sentry|firebase|facebook|admob|amplitude|mixpanel"
```

---

## Passo 2: o núcleo que se aplica a **todas** as apps

Isto verifica-se sempre, seja a app o que for.

| Guideline | O que exige | Como se verifica |
|---|---|---|
| **Before You Submit** | Sem crashes, metadados completos, contacto atualizado, **acesso total do revisor**, backend ligado, notas de review com o que não é óbvio | Build de release num dispositivo; ler as notas de review |
| **1.5** Developer Information | Forma fácil de contactar o developer, na app e no Support URL | Ecrã de ajuda/sobre + campo do ASC |
| **1.6** Data Security | Medidas de segurança adequadas para os dados tratados | HTTPS, segredos fora do bundle, tokens em Keychain/SecureStore |
| **2.1** App Completeness | Versão final, sem placeholders, sem URLs mortos; conta demo ou modo demo se houver login | Passo 1 #8, #13, #14 |
| **2.3.1(a)** | Sem funcionalidades escondidas ou não documentadas; **todas as novidades descritas em detalhe** nas notas de review (descrições genéricas são chumbadas) | Notas de review |
| **2.3.3** Screenshots | Mostram a app **em uso**, não o ecrã de login nem o splash | Ficheiros submetidos |
| **2.3.5 / 2.3.6 / 2.3.7** | Categoria certa, classificação etária honesta, nome único até 30 caracteres, keywords sem marcas alheias | ASC |
| **2.3.8** | Ícones, screenshots e previews adequados a 4+, mesmo que a app seja 12+ | ASC |
| **2.3.9** | Direitos sobre todo o material dos ícones e screenshots; dados de conta **fictícios** nas imagens | Screenshots |
| **2.3.10** | Sem referências a outras plataformas (Android, Google Play) na app ou nos metadados | `grep -rni "android\|google play" ` nos textos públicos |
| **2.3.12** | O "What's New" descreve as mudanças reais; genérico só para correções e desempenho | ASC |
| **2.5.1** | Só APIs públicas, a correr no SO atual, sem tecnologias descontinuadas | Warnings de build, versões do SDK |
| **2.5.2** | App autocontida; não descarrega nem executa código que mude funcionalidade | OTA de JS é tolerado se não mudar a funcionalidade revista |
| **2.5.4** | Background modes só para o fim declarado | `UIBackgroundModes` vs. o que a app faz mesmo |
| **2.5.5** | **Funciona em redes só IPv6** | A review testa em NAT64. Testar com "Internet Sharing" em modo NAT64 no Mac |
| **4.1** Copycats | Nome, ícone e marca próprios | Comparar com o que já existe na App Store |
| **4.2** Minimum Functionality | Mais do que um site reempacotado; utilidade própria e duradoura | O argumento tem de caber em duas frases nas notas de review |
| **4.3** Spam | Um binário, não um por cidade/clube/edição; não indistinguível do que já existe | Bundle IDs do developer |
| **5.1.1(i)** Privacy Policy | Link no ASC **e dentro da app**, a dizer que dados recolhe, como, para quê, com quem partilha, e como se pede o apagamento | Ecrã na app + URL |
| **5.1.1(ii)** | Consentimento para recolha, *purpose strings* que descrevem mesmo o uso, forma de retirar consentimento | Textos das permissões |
| **5.1.1(iii)** | Minimização: só se pede acesso ao que a funcionalidade principal exige | Cada permissão tem de ter um dono no código |
| **5.1.2** | Não partilhar dados pessoais sem permissão; ATT se houver tracking | SDKs do Passo 1 #7 |
| **5.2.1 / 5.2.2** | Direitos sobre marcas, conteúdos e serviços de terceiros usados | Nomes de federações, ligas, competições |
| **5.6** Code of Conduct | Sem manipulação de reviews, identidade do developer verdadeira, app mantida | Conta do ASC |

---

## Passo 3: filtro de aplicabilidade

Só entram no relatório as linhas cuja condição se verifica. As outras vão para a secção
"não se aplica", cada uma com o seu motivo.

| Se a app... | ...então aplicam-se |
|---|---|
| Tem conteúdo editorial, imagens ou texto de terceiros | 1.1 (todas) |
| Deixa utilizadores publicar, comentar ou falar entre si | 1.2 (filtro, denúncia, bloqueio, contacto publicado) e 1.2.1 |
| É dirigida a crianças ou entra na categoria Kids | 1.3, 5.1.4, 2.3.8 |
| Toca em saúde, medicação, condução ou desafios físicos | 1.4.1 a 1.4.5 |
| Recolhe denúncias de crime | 1.7 |
| Vende alguma coisa, dentro ou fora da app | 3.1.1, 3.1.2, 3.1.3, 3.1.5, 3.2 |
| Tem subscrições | 3.1.2 (preço, duração, renovação, cancelamento, restauro) |
| Usa login de terceiros (Google, Facebook, X, LinkedIn, Amazon, WeChat) | **4.8**: obriga a oferecer alternativa equivalente, tipicamente Sign in with Apple |
| Permite criar conta | **5.1.1(v)**: apagar a conta **dentro da app**, obrigatório |
| Funciona só com login sem ter funcionalidades de conta | 5.1.1(v): tem de deixar usar sem login |
| Usa localização | 5.1.5, e a *purpose string* respetiva |
| Usa HealthKit ou dados de saúde | 5.1.3, 5.1.2(vi) |
| Usa ARKit | 4.2.1 |
| Tem widgets, extensões, teclado ou App Clips | 4.4, 4.4.1, 4.4.2, 2.5.16, 2.5.18 |
| Envia notificações push | 4.5.3, 4.5.4 (não podem ser obrigatórias para a app funcionar, nem publicidade sem opt-in) |
| Usa Apple Pay | 4.9 |
| Usa Sirikit ou Shortcuts | 2.5.11 |
| Grava ecrã, áudio ou vídeo do utilizador | 2.5.14 (consentimento explícito e indicação visível) |
| Mostra conteúdo web de terceiros | 2.5.6 (WebKit), 4.2.2 |
| Aloja mini-apps, jogos em streaming, chatbots, plug-ins ou emuladores | 4.7 (todas) |
| É gerada por template ou app builder | 4.2.6 |
| Tem sorteios, concursos ou jogo a dinheiro | 5.3 (todas) |
| É VPN | 5.4 |
| É MDM | 5.5 |
| Vai para a Mac App Store | 2.4.5 (i) a (ix) |
| Vai para a Apple TV | 2.4.3 |
| Vai para pré-encomenda | 2.3.11 |
| Anuncia in-app events | 2.3.13 |
| É banca, seguros, saúde, cannabis, viagem aérea ou cripto | 5.1.1(ix): tem de ser submetida por pessoa coletiva |

---

## Passo 4: os chumbos mais comuns, por ordem de frequência

Verificar estes primeiro. É aqui que a maioria das submissões cai.

1. **2.1(a) — o revisor não conseguiu entrar.** Login sem conta demo, PIN gerado noutro sistema,
   código por SMS, backend desligado, hardware que o revisor não tem. Se a app precisa de algo que
   vem de fora (um QR, um PIN, um evento a decorrer), tem de haver **modo demo** ou credenciais
   válidas e duradouras, mais instruções passo a passo nas notas de review.
2. **5.1.1(i) — política de privacidade em falta ou incompleta.** Não basta o campo do ASC: tem de
   estar acessível **dentro da app** e cobrir retenção e apagamento. Basta a app tratar dados de
   pessoas (mesmo de terceiros, não do utilizador) para ser obrigatória.
3. **2.3.1(a) — notas de review genéricas.** "Bug fixes and improvements" chumba quando há
   funcionalidade nova. Descrever cada uma, e onde se chega a ela na app.
4. **5.1.1(v) — não há como apagar a conta na app.** Se se cria conta, tem de se poder apagar sem
   sair da app e sem escrever um email.
5. **2.5.5 — a app morre em IPv6.** Endereços literais IPv4, bibliotecas antigas, backend só A record.
6. **4.2 — funcionalidade mínima.** Companion de um site, catálogo, wrapper de WebView. A defesa é
   ter funcionalidade que só existe na app, e dizê-lo nas notas de review.
7. **2.3.3 — screenshots do ecrã de login.** Têm de mostrar a app a ser usada.
8. **1.5 — nenhuma forma de contacto** na app nem no Support URL.
9. **4.8 — login de terceiros sem alternativa.** Só é exigido se houver login social; sistema
   próprio da empresa está isento.
10. **3.1.1 — venda de conteúdo digital fora do IAP**, ou link para pagar noutro sítio.
11. **2.3.10 — menções ao Android** nos textos, screenshots ou ecrãs da app.
12. **5.2.1 — marcas de terceiros** usadas sem licença: logos de clubes, nomes de competições,
    escudos de federações.
13. **2.4.1 — app de iPhone que não corre em iPad.** `supportsTablet: false` não é chumbo, mas o
    revisor testa na mesma em iPad em modo compatibilidade; tem de funcionar lá.

---

## Passo 5: o que não está no código

Isto não se verifica com `grep`. Vai para o relatório como lista de confirmação para o utilizador.

- [ ] **Privacy Policy URL** preenchido e a responder
- [ ] **Support URL** preenchido e a responder
- [ ] **App Privacy** ("privacy nutrition label") preenchido e **coerente com os SDKs reais**
- [ ] **Age rating** respondido com honestidade
- [ ] **Categoria** primária e secundária
- [ ] **Screenshots** para todos os tamanhos exigidos, a mostrar a app em uso
- [ ] **Descrição, subtítulo e keywords** sem preços, sem marcas alheias, sem outras plataformas
- [ ] **What's New** com as mudanças reais desta versão
- [ ] **Notas de review**: conta demo ou modo demo, passos para chegar ao que é novo, explicação do
      que não é óbvio, documentação de suporte se for caso disso
- [ ] **Contacto do App Review** atualizado (telefone e email que alguém atende)
- [ ] **Export compliance** respondido (`ITSAppUsesNonExemptEncryption` ou o formulário do ASC)
- [ ] **Backend em produção**, com dados de exemplo, e a aguentar a janela da review
- [ ] **Sign in with Apple** configurado, se o Passo 3 o exigir
- [ ] **Contrato de apps pagas** assinado, se a app não for grátis

---

## Passo 6: formato do relatório

Três blocos, por esta ordem. Sem preâmbulo.

### 1. Veredicto

Uma frase: pronta para submeter, pronta com ressalvas, ou não pronta. Seguida das falhas por
resolver, se as houver, em lista curta.

### 2. Verificado

| Guideline | Estado | Evidência | O que fazer |
|---|---|---|---|
| 2.1(a) | risco | Ligação exige PIN gerado na plataforma (`src/...`) | Criar PIN de longa duração e pô-lo nas notas de review |

`Estado` é `conforme`, `risco` ou `falha`. `Evidência` é um caminho de ficheiro, um campo do ASC, ou
`não verificável a partir do código`. Nunca deixar a coluna vazia.

### 3. Não se aplica

Lista corrida, uma linha por regra, com o motivo. Exemplo:
`3.1 a 3.2 — a app é grátis, sem IAP nem pagamentos.`

Se o utilizador pediu só uma parte (por exemplo, só a secção Legal), o filtro do Passo 3 continua a
correr na mesma: uma regra da secção 5 pode depender de um facto da secção 2.
