#!/bin/bash

# Inicializa variáveis
NUM_CHARS=""
ITERATIONS=""
ALGO=""
KEYWORD=""

# Loop para processar as flags (-c, -i, -a, -p)
while getopts "c:i:a:p:" opt; do
  case $opt in
    c)
      NUM_CHARS="$OPTARG"
      ;;
    i)
      ITERATIONS="$OPTARG"
      ;;
    a)
      ALGO="$OPTARG"
      ;;
    p)
      KEYWORD="$OPTARG"
      ;;
    \?)
      echo "Opção inválida: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "A opção -$OPTARG requer um argumento." >&2
      exit 1
      ;;
  esac
done

# Definir valor padrão para ITERATIONS se não for informado
ITERATIONS=${ITERATIONS:-1}

# Validar se os parâmetros obrigatórios (KEYWORD e ALGO) foram preenchidos
if [ -z "$KEYWORD" ] || [ -z "$ALGO" ]; then
    echo "Uso: $0 -p <palavra_chave> -a <algoritmo> [-c <num_caracteres>] [-i <num_iteracoes>]"
    echo "  -p: Palavra-chave (seed) para gerar a senha (obrigatório)"
    echo "  -a: Algoritmo de hash (obrigatório: md5, sha256, sha512)"
    echo "  -c: Número de caracteres (opcional, se omitido, retorna o hash completo)"
    echo "  -i: Número de iterações (opcional, padrão: 1)"
    echo ""
    echo "Exemplo: $0 -p minha_senha -a sha256 -c 10 -i 5"
    exit 1
fi

# Selecionar comando baseada no algoritmo
case $ALGO in
    md5)
        HASH_CMD="md5sum"
        ;;
    sha256)
        HASH_CMD="sha256sum"
        ;;
    sha512)
        HASH_CMD="sha512sum"
        ;;
    *)
        echo "Algoritmo inválido. Use: md5, sha256 ou sha512"
        exit 1
        ;;
esac

CURRENT_VAL=$KEYWORD

for (( i=1; i<=$ITERATIONS; i++ )); do
    # Gera o hash completo e atualiza CURRENT_VAL para a próxima iteração
    CURRENT_VAL=$(echo -n "$CURRENT_VAL" | $HASH_CMD | awk '{print $1}')
done

# Corta o resultado final APENAS se NUM_CHARS foi especificado
if [ -z "$NUM_CHARS" ]; then
    echo "$CURRENT_VAL"
else
    echo "$CURRENT_VAL" | cut -c 1-$NUM_CHARS
fi