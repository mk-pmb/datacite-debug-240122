#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
# in our .rc: DC_DOI_PREFIX='10.82109/anno.test.'
(
DOI='datacite-test-minimum-lvr-1'
export TMP_BFN='tmp.minimum'

../putdoi.sh "$DOI" --file minimum.payload.json
../putdoi.sh "$DOI" event publish

) | tee -- tmp.minimum.log
