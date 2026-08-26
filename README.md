# Amnesia Pass Generator

Um gerador de senhas determinístico baseado em hash SHA512 iterativo. Dado uma palavra-chave, um username/e-mail e um site/aplicativo, a mesma senha é sempre reproduzida sem precisar armazená-la.

Este repositório inclui duas implementações independentes do mesmo algoritmo:

- `amnesiapassgen.sh` — CLI em Bash usando `sha512sum` do coreutils.
- `docs/` — Aplicação web estática (vanilla JS + CryptoJS), publicada via GitHub Pages e instalável como PWA offline.

**GitHub Page:** [AmnesiaPassGenerator](https://brandonalmeida.github.io/AmnesiaPassGenerator)

---

## Como funciona

1. Concatena o username/e-mail com o site/aplicativo formando o salt (`username + site`).
2. Concatena a palavra-chave com o salt no formato `keyword:salt` (se algum dos dois for fornecido).
3. Calcula SHA512 do resultado e re-hasha o hex digest por N iterações.
4. Trunca o hash final para o número de caracteres desejado (ou retorna o hash completo).
5. Aplica prefixo e sufixo opcionais ao resultado.

O processo é determinístico: os mesmos parâmetros sempre produzem a mesma saída.

---

## CLI — Uso

```bash
./amnesiapassgen.sh -p <palavra_chave> [-c <num_caracteres>] [-i <num_iteracoes>] [-u <username>] [-w <site>] [-x <prefixo>] [-y <sufixo>] [-R]
```

### Parâmetros

| Flag | Descrição | Obrigatório |
|------|-----------|-------------|
| `-p` | Palavra-chave (seed mestra) | Sim |
| `-c` | Comprimento da senha em caracteres — máximo 128 (sem valor = hash completo de 128 caracteres) | Não |
| `-i` | Número de iterações (padrão: `1`) | Não |
| `-u` | Username ou e-mail (combinado com `-w` forma o salt) | Não |
| `-w` | Site ou aplicativo (combinado com `-u` forma o salt) | Não |
| `-x` | Prefixo adicionado ao resultado final | Não |
| `-y` | Sufixo adicionado ao resultado final | Não |
| `-R` | Gera e exibe a receita (string base64) junto com a senha | Não |

### Exemplos

Senha de 40 caracteres com 10 iterações:

```bash
./amnesiapassgen.sh -p "minhasenhasecreta" -c 40 -i 10 -u usuario@gmail.com -w github -x "#T" -y "#"
```

Hash completo (sem truncamento), iteração padrão:

```bash
./amnesiapassgen.sh -p "minhasenhasecreta" -u usuario@gmail.com -w email
```

Para não gravar a palavra-chave no histórico do Bash (`HISTCONTROL=ignoreboth` no `~/.bashrc`), inicie o comando com um espaço:

```bash
 ./amnesiapassgen.sh -p "minhasenhasecreta" -c 32 -i 5 -u usuario@banco.com -w banco
```

### Receitas (seed para o cofre)

Uma receita é uma string base64 que codifica todos os parâmetros **exceto a palavra-chave**. Armazene-a no campo de senha do cofre — se o cofre vazar, o atacante tem a receita mas não consegue derivar a senha sem a palavra-chave, que fica só na sua cabeça.

**Gerar receita junto com a senha:**

```bash
./amnesiapassgen.sh -p "minhasenhasecreta" -u usuario@gmail.com -w github -c 32 -i 5 -R
```

```
Passwd: 3a9f...c12e
Length: 32
Receita: apg:eyJhIjoic2hhNTEyIiwidSI6InVzdWFyaW9AZ21haWwuY29tIiwidyI6ImdpdGh1YiIsImMiOiIzMiIsImkiOiI1In0=
```

**Usar receita para gerar a senha** (o que você faz ao consultar o cofre):

```bash
./amnesiapassgen.sh -r "apg:eyJhIjoic2hhNT..." -p "minhasenhasecreta"
```

Flags CLI passadas junto com `-r` sobrepõem os valores da receita.

### Descriptografar perfis exportados da versão web

O script pode ler o arquivo `.json` exportado pela versão web, descriptografar um perfil e gerar a senha correspondente em um único comando:

```bash
./amnesiapassgen.sh -d -f apg-profiles-2025-06-19.json -n "GitHub" -p "minhasenhamestra"
```

**Flags do modo descriptografar:**

| Flag | Descrição | Obrigatório |
|------|-----------|-------------|
| `-d` | Ativa o modo de descriptografia | Sim |
| `-f` | Caminho para o arquivo `.json` exportado | Sim |
| `-n` | Nome do perfil a descriptografar | Sim |
| `-p` | Palavra-chave usada ao salvar o perfil na web | Sim |
| `-c` `-i` `-x` `-y` | Sobrepõem os valores do perfil, se necessário | Não |

Saída de exemplo:

```
Perfil 'GitHub' descriptografado com sucesso.
  Username     : usuario@gmail.com
  Site         : github
  Caracteres   : 40
  Iterações    : 10
  Prefixo      : #T
  Sufixo       : #

Passwd: #T3a9f...c12e#
Length: 44
```

**Requisitos adicionais para o modo descriptografar:**
- Python 3
- Pacote `cryptography`: `pip install cryptography`

### Requisitos

- Bash
- Coreutils (`sha512sum`)
- Python 3 + `pip install cryptography` *(somente para descriptografar perfis e usar receitas)*

---

## Versão Web (GitHub Pages + PWA)

A aplicação web está em `docs/` e pode ser publicada no GitHub Pages. Funciona 100% no navegador — nenhum dado é enviado a servidores. Instalável como app offline via PWA.

### Recursos

- Geração de senha idêntica ao CLI (mesmo algoritmo SHA512 iterativo).
- Todos os campos sensíveis têm toggle show/hide.
- Instalável como PWA (modo standalone, uso offline via Service Worker).
- CryptoJS carregado localmente — sem dependência de CDN para a geração de senhas.

### Perfis Salvos

A versão web permite salvar e carregar configurações de senha (perfis) diretamente no `localStorage` do navegador, com criptografia de ponta a ponta.

**O que é salvo:** palavra-chave, username, site, número de caracteres, iterações, prefixo, sufixo — tudo cifrado. Nenhum dado sensível fica em texto claro no armazenamento.

**Criptografia usada:**
- Derivação de chave: **PBKDF2** (SHA-256, 200.000 iterações, salt aleatório de 16 bytes por perfil)
- Cifra: **AES-GCM-256** (nonce aleatório de 12 bytes por salvamento)
- A tag de autenticação do GCM garante integridade — uma palavra-chave errada resulta em falha de autenticação, sem vazar dados

**Fluxo de uso:**

1. Preencha o formulário com todos os campos desejados, incluindo a palavra-chave.
2. Clique em **Salvar Perfil Atual** e dê um nome ao perfil.
3. Posteriormente, selecione o perfil no dropdown e clique em **Carregar**.
4. Insira a palavra-chave no modal de descriptografia — todos os campos são restaurados automaticamente.

**Import / Export:**

Os perfis podem ser exportados para um arquivo `.json` (os blobs permanecem cifrados, sem exposição de dados sensíveis) e importados em outro dispositivo ou navegador. Em caso de conflito de nomes, é possível sobrescrever ou ignorar os perfis existentes individualmente.

### Como publicar no GitHub Pages

1. No GitHub, vá em **Settings → Pages**.
2. Em **Source**, selecione **Deploy from a branch**.
3. Em **Branch**, selecione `main` e a pasta `/docs`.
4. Salve e aguarde o link do site.

### Como instalar no Android (Chrome)

1. Acesse o site publicado via HTTPS.
2. No menu do Chrome, toque em **Instalar app**.
3. O app será adicionado à tela inicial em modo standalone.

---

## Boas práticas

- Use uma palavra-chave longa e não óbvia (frase completa, não uma palavra).
- Use um username e site diferentes para cada serviço — evita que a mesma senha base seja reutilizada diretamente.
- Para uso com cofre de senhas: gere uma receita (`-R`) e armazene-a no cofre no lugar da senha — mesmo que o cofre vaze, a senha não pode ser derivada sem a palavra-chave.
- A palavra-chave é o ponto único de falha: se for descoberta, todas as senhas derivadas ficam expostas.
- Ao usar o CLI, evite expor a palavra-chave no histórico do terminal ou em clipboards de apps não confiáveis.
