#!/bin/bash
set -e

LANG=en_US.UTF-8

SYMBOLS=("$@")

: "${COLOR_BOLD:=\e[1;37m}"
: "${COLOR_GREEN:=\e[32m}"
: "${COLOR_RED:=\e[31m}"
: "${COLOR_RESET:=\e[00m}"
: "${DIM:=\e[2m}"

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
printf "%-20s%-20s%-20s%-20s%-20s%s%s%s%s\n" "Symbol" "Price" "Currency" "Difference" "Diff. in %" "52-Week-Range" 
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

if ! $(type jq > /dev/null 2>&1); then
  echo "'jq' is not in the PATH. (See: https://stedolan.github.io/jq/)"
  exit 1
fi

if [ -z "$SYMBOLS" ]; then
  echo "Usage: ./ticker.sh AAPL MSFT GOOG BTC-USD"
  exit
fi

FIELDS=(symbol marketState regularMarketPrice regularMarketChange regularMarketChangePercent \
  preMarketPrice preMarketChange preMarketChangePercent postMarketPrice postMarketChange postMarketChangePercent currency fiftyTwoWeekRange)
API_ENDPOINT="https://query1.finance.yahoo.com/v7/finance/quote?"

symbols=$(IFS=,; echo "${SYMBOLS[*]}")
fields=$(IFS=,; echo "${FIELDS[*]}")

results=$(curl --silent "$API_ENDPOINT&fields=$fields&symbols=$symbols" \
  | jq '.quoteResponse .result')

query () {
  echo $results | jq -r ".[] | select (.symbol == \"$1\") | .$2"
}

for symbol in $(IFS=' '; echo "${SYMBOLS[*]}"); do
  if [ -z "$(query $symbol 'marketState')" ]; then
    printf 'No results for symbol "%s"\n' $symbol
    continue
  fi

  if [ $(query $symbol 'marketState') == "PRE" ] \
    && [ "$(query $symbol 'preMarketChange')" != "0" ] \
    && [ "$(query $symbol 'preMarketChange')" != "null" ]; then
    nonRegularMarketSign='*'
    price=$(query $symbol 'preMarketPrice')
    diff=$(query $symbol 'preMarketChange')
    percent=$(query $symbol 'preMarketChangePercent')
    curr=$(query $symbol 'currency')
  elif [ $(query $symbol 'marketState') != "REGULAR" ] \
    && [ "$(query $symbol 'postMarketChange')" != "0" ] \
    && [ "$(query $symbol 'postMarketChange')" != "null" ]; then
    nonRegularMarketSign='*'
    price=$(query $symbol 'postMarketPrice')
    diff=$(query $symbol 'postMarketChange')
    percent=$(query $symbol 'postMarketChangePercent')
    curr=$(query $symbol 'currency')
  else
    nonRegularMarketSign=''
    price=$(query $symbol 'regularMarketPrice')
    diff=$(query $symbol 'regularMarketChange')
    percent=$(query $symbol 'regularMarketChangePercent')
    curr=$(query $symbol 'currency')
    annualrange=$(query $symbol 'fiftyTwoWeekRange')
  fi

  if [ "$diff" == "0" ]; then
    color=
  elif ( echo "$diff" | grep -q ^- ); then
    color=$COLOR_RED
  else
    color=$COLOR_GREEN
  fi

  printf "%-20s$COLOR_BOLD%-20.2f$COLOR_RESET" $symbol $price
  printf "%-20s" $curr
  printf "$color%-20.2f%-10s$COLOR_RESET" $diff $(printf "(%.2f%%)" $percent)
  printf "$DIM%-10s$COLOR_RESET" "$nonRegularMarketSign"
  printf "%s%s%s\n" $annualrange

done

  printf '%*s' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
  printf "$DIM\n%s\n$COLOR_RESET" "* Pre- or postmarket change"
