# Amnesia Pass Generator

Um gerador de senhas determinístico simples em Bash que cria hashes iterativos baseados em uma palavra-chave.
Este repositório também inclui uma versão web em `docs/`, compatível com GitHub Pages e com suporte a PWA (uso offline).

## Como funciona

O script recebe uma palavra-chave, gera um hash (MD5 - não recomendado, SHA256 ou SHA512), repete esse processo por um número definido de iterações para garantir entropia, e corta o resultado para um tamanho específico no final. Isso permite gerar senhas reproduzíveis (determinísticas) e seguras.

## Uso

```bash
./amnesiapassgen.sh -p <palavra_chave> -a <algoritmo> [-c <num_caracteres>] [-i <num_iteracoes>] [-s <salt_servico>] [-x <prefixo>] [-y <sufixo>]
```

### Parâmetros (Flags)

*   `-p <palavra>`: **Obrigatório.** A string inicial (seed/senha mestra).
*   `-a <algo>`: **Obrigatório.** O algoritmo de hash a ser utilizado (`md5` - não recomendado, `sha256`, `sha512`).
*   `-c <num>`: O comprimento desejado da senha final. **Opcional.** Se omitido, o hash completo será retornado.
*   `-i <num>`: Quantas vezes o processo de hash será repetido (mais iterações = mais demora = mais seguro contra força bruta). **Opcional.** Padrão: `1`.
*   `-s <texto>`: Um salt/identificador do serviço (ex.: `github`, `gmail`) concatenado à palavra-chave antes do hashing. **Opcional**, mas recomendado para evitar reutilizar a mesma senha base em serviços diferentes.
*   `-x <texto>`: Prefixo **opcional** adicionado ao resultado final.
*   `-y <texto>`: Sufixo **opcional** adicionado ao resultado final.

## Exemplos

Gerar uma senha de 10 caracteres, com 5 iterações usando SHA256:

```bash
./amnesiapassgen.sh -p "minhasenhasecreta" -a sha256 -c 10 -i 5 -s "github" -x "#meunome" -y "#sobrenome"
```

Gerar uma senha de 32 caracteres, com 1 iteração usando SHA512:

```bash
./amnesiapassgen.sh -p "admin" -a sha512 -c 32 -i 1
```

Gerar o hash completo (sem corte), com 1 iteração (padrão) usando SHA512:

```bash
./amnesiapassgen.sh -p "umaoutrasenha" -a sha512 -s "meuservico"
```

Gerar uma senha curta com MD5 (apenas para compatibilidade; não recomendado):

```bash
./amnesiapassgen.sh -p "legacy" -a md5 -c 16 -i 1
```

## Requisitos

*   Bash
*   Coreutils (md5sum, sha256sum, sha512sum)

## Versão Web (GitHub Pages + PWA)

A aplicação web está em `docs/` e pode ser publicada no GitHub Pages. Ela é compatível com PWA, permitindo instalação no celular e uso offline.

### Recursos principais

*   Funciona 100% no navegador (sem envio de dados para servidores).
*   Pode ser instalada como app (modo standalone) em dispositivos móveis.
*   Suporte offline via Service Worker.
*   Biblioteca CryptoJS é carregada localmente para independência de CDN.

### Como publicar no GitHub Pages

1. No GitHub, vá em **Settings → Pages**.
2. Em **Source**, selecione **Deploy from a branch**.
3. Em **Branch**, selecione `main` e a pasta `/docs`.
4. Salve e aguarde o link do site.

### Como instalar no Android (Chrome)

1. Acesse o site publicado via HTTPS.
2. No menu do Chrome, toque em **Instalar app**.
3. O app será adicionado à tela inicial em modo standalone.

## Boas práticas e sugestões de uso

1. Use uma seed/senha mestra forte (frase longa e não óbvia) e um salt por serviço para evitar reutilização direta.
2. Ao usar o script, cuide para não expor a seed/salt no histórico do terminal ou em clipboards; prefira limpar o histórico sensível e evitar colar em apps não confiáveis.
