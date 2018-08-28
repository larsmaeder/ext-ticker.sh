# Extended ticker.sh

> Extended real-time command-line stock ticker based on pstadler`s ticker.sh.

`ext-ticker.sh` is a simple shell script using the Yahoo Finance API as a data source. It features colored output and is able to display pre- and post-market prices.

![ext-ticker.sh](https://raw.githubusercontent.com/larsmaeder/ext-ticker.sh/master/ext-ticker-sh.png)

## Install

```sh
$ curl -o ext-ticker.sh https://raw.githubusercontent.com/larsmaeder/ticker.sh/master/ext-ticker.sh
```

Make sure to install [jq](https://stedolan.github.io/jq/), a versatile command-line JSON processor.

## Usage

```sh
# Single symbol:
$ ./ext-ticker.sh AAPL

# Multiple symbols:
$ ./ext-ticker.sh AAPL MSFT GOOG BTC-USD

# Read from file:
$ echo "AAPL MSFT GOOG BTC-USD" > ~/.ext-ticker.conf
$ ./ext-ticker.sh $(cat ~/.ext-ticker.conf)

# Update every five seconds:
$ while true; do clear; ./ext-ticker.sh AAPL MSFT GOOG BTC-USD; sleep 5; done
```

This script works well with [GeekTool](https://www.tynsoe.org/v2/geektool/) and similar software:

```sh
# GeekTool example script:

PATH=/usr/local/bin:$PATH # make sure to include the path where jq is located
~/GitHub/ext-ticker.sh/ext-ticker.sh AAPL MSFT GOOG BTC-USD
```
