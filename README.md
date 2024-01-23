
<!--#echo json="package.json" key="name" underline="=" -->
datacite-debug-240122
=====================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Debugging the DataCite API.
<!--/#echo -->

* [DataCite API docs: PUT DOI
  ](https://support.datacite.org/docs/updating-metadata-with-the-rest-api)



Setup
-----

1.  Clone this repo.
1.  Make a local copy of [the example config](example-config.rc):
    `cp -nvT -- example-config.rc config.rc`
1.  Set password-worthy permissions on your local config file:
    `chmod a=,u=rw -- config.rc`
1.  Edit your local config (`config.rc`), set test parameters, save.
    * `DC_DOI_PREFIX` is treated as a dumb string that knows nothing
      about the DOI standard's notion of "prefix" and "suffix".
1.  Install [`jq`, the command-line JSON processor
    ](https://github.com/stedolan/jq/).
    * Alternatively, set `JSON_INDENTER` in your config to a command
      that reads JSON from stdin and prints prettier JSON to stdout.


CLI syntax
----------

### `./putdoi.sh <doi> [<key> <val>]`

* `<doi>` is the DOI you want to work on, or `/` (just a slash)
  if you want to use the `DC_DEFAULT_DOI` from your config.
  Either way, your `DC_DOI_PREFIX` will be added in front.
* `<key>` is the attribute you want to change to `<val>`.
  * If both are empty or missing, only the `doi` attribute will
    be sent. This can be used to create a blank new draft, or to
    query the current DOI information without changes.
  * If `<val>` doesn't look like a JSON value, the script will attempt
    a very simplistic conversion to a JSON string.
    While this is sufficient for very simple values, it's always safer
    to provide proper JSON as `<val>`.


### `./putdoi.sh <doi> --file <path>`

Upload a custom payload from a JSON file.


### Examples

```text
./putdoi.sh / publicationYear 2024
./putdoi.sh / creators '[{"nameType":"Personal","name":"Josiah S. Carberry"}]'
./putdoi.sh / titles '[{"title":"Debugging the DataCite API"}]'
./putdoi.sh / rightsList '[]'
```






<!--#toc stop="scan" -->



Known issues
------------

* Needs more/better tests and docs.




&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
ISC
<!--/#echo -->
