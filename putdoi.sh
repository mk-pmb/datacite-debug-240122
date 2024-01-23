#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function putdoi_cli_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  # cd -- "$SELFPATH" || return $?

  local JSON_INDENTER='jq --sort-keys'
  local DC_LOGIN=
  local DC_DOI_PREFIX=
  local DC_DEFAULT_DOI=
  local DC_DOI=
  local KEY= VAL=

  source -- "$SELFPATH"/config.rc
  [ -n "$DC_LOGIN" ] || return 4$(echo E: "Empty DC_LOGIN variable!" >&2)

  [ -n "$DC_DOI" ] || DC_DOI="$1"; shift
  KEY="$1"; shift
  VAL="$1"; shift
  [ -n "${DC_DOI%/}" ] || DC_DOI="$DC_DEFAULT_DOI"
  [ -n "$DC_DOI" ] || return 4$(echo E: "Empty DC_DOI variable!" >&2)
  DC_DOI="$DC_DOI_PREFIX$DC_DOI"
  local URL="https://api.test.datacite.org/dois/$DC_DOI"
  [ -n "$TMP_BFN" ] || local TMP_BFN="tmp.$(printf '%(%H%M%S)T' -1)"

  local APOS="'" QUOT='"'
  prepare_payload || return $?
  preview_file "$TMP_BFN".payload.json

  local CURL_OPT=(
    --request PUT
    --header 'Content-Type:application/vnd.api+json'
    --data "@$TMP_BFN".payload.json
    --silent -- "$URL"
    )
  echo "# curl --user '***:***' ${CURL_OPT[*]}"
  local SAVED_JSON="$TMP_BFN".reply.json
  curl --user "$DC_LOGIN" "${CURL_OPT[@]}" >"$SAVED_JSON"
  rm -- "$TMP_BFN".payload.json
  echo

  [ "$(tail --bytes=1 -- "$SAVED_JSON")" == '}' ] && echo >>"$SAVED_JSON"
  prettyprint_reply || return $?

  preview_file "$SAVED_JSON"
  grep -nPe '^\s*"state":\s*"\w+"' -- "$SAVED_JSON"
  echo
}


function prepare_payload () {
  local DEST="$TMP_BFN".payload.json
  if [ "$KEY" == --file ]; then
    ln --verbose --symbolic --no-target-directory -- "$VAL" "$DEST" \
      || return $?$(echo E: 'Failed to create payload symlink!' >&2)
    return 0
  fi

  printf -- '{"data":{"type":"dois","attributes":{\n  "doi": "%s"' \
    "$DC_DOI" >"$DEST" ||return 4$(
    echo E: 'Failed to write payload DOI.' >&2)
  case "$VAL" in
    '['*']' | '{'*'}' | '"'*'"' ) ;;
    true | false | null ) ;;
    *[^0-9]* | '' )
      VAL="${VAL//\\/\\u005C}"
      VAL="${VAL//$QUOT/\\u0022}"
      VAL="$QUOT$VAL$QUOT"
      ;;
    * ) ;;
  esac
  [ "$KEY:$VAL" == ':""' ] || printf -- ',\n  "%s": %s' "$KEY" "$VAL" \
    >>"$DEST" || return 4$(
    echo E: 'Failed to write custom payload attribute.' >&2)
  echo $'\n}}}' >>"$DEST" || return 4$(
    echo E: 'Failed to write payload trailer.' >&2)
}


function preview_file () {
  echo "$(head --verbose --bytes=512 -- "$1" | head --lines=5)"
}


function prettyprint_reply () {
  local ORIG="$SAVED_JSON"
  if grep -qPe '"errors?":' -- "$ORIG"; then
    SAVED_JSON="$TMP_BFN".error.json
    sed -re 's~(\S)(\{")~\1\n  \2~g' -- "$ORIG" \
      | sed -re '/^.{120}/s~",\s*"~",\n    "~g' \
      >"$SAVED_JSON" || return $?
  else
    SAVED_JSON="$TMP_BFN".ok.json
    $JSON_INDENTER <"$ORIG" | sed -re '1{N;N;s~\{\n\s*~{ ~g};$s~$~\n~' \
      >"$SAVED_JSON" || return $?
  fi
  rm -- "$ORIG"
}










putdoi_cli_main "$@"; exit $?
