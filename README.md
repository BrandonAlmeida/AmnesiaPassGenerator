# Amnesia Pass Generator

Um gerador de senhas determinístico simples em Bash que cria hashes iterativos baseados em uma palavra-chave.

## Como funciona

O script recebe uma palavra-chave, gera um hash (MD5, SHA256 ou SHA512), repete esse processo por um número definido de iterações para garantir entropia, e corta o resultado para um tamanho específico no final. Isso permite gerar senhas reproduzíveis (determinísticas) e seguras.

## Uso

```bash
./amnesiapassgen.sh -p <palavra_chave> -a <algoritmo> [-c <num_caracteres>] [-i <num_iteracoes>]
```

### Parâmetros (Flags)

*   `-p <palavra>`: **Obrigatório.** A string inicial (seed/senha mestra).
*   `-a <algo>`: **Obrigatório.** O algoritmo de hash a ser utilizado (`md5`, `sha256`, `sha512`).
*   `-c <num>`: O comprimento desejado da senha final. **Opcional.** Se omitido, o hash completo será retornado.
*   `-i <num>`: Quantas vezes o processo de hash será repetido (mais iterações = mais demora = mais seguro contra força bruta). **Opcional.** Padrão: `1`.

## Exemplos

Gerar uma senha de 10 caracteres, com 5 iterações usando SHA256:

```bash
./amnesiapassgen.sh -p "minhasenhasecreta" -a sha256 -c 10 -i 5
```

Gerar uma senha de 32 caracteres, com 1 iteração usando MD5:

```bash
./amnesiapassgen.sh -p "admin" -a md5 -c 32 -i 1
```

Gerar o hash completo (sem corte), com 1 iteração (padrão) usando SHA512:

```bash
./amnesiapassgen.sh -p "umaoutrasenha" -a sha512
```

## Requisitos

*   Bash
*   Coreutils (md5sum, sha256sum, sha512sum)