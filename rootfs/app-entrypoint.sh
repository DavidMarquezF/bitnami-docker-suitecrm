#!/bin/bash
set -e

function initialize {
    # Package can be "installed" or "unpacked"
    status=`nami inspect $1`
    if [[ "$status" == *'"lifecycle": "unpacked"'* ]]; then
        # Clean up inputs
        inputs=""
        if [[ -f /$1-inputs.json ]]; then
            inputs=--inputs-file=/$1-inputs.json
        fi
        nami initialize $1 $inputs
    fi
}

# Adding cron entries
ln -fs /opt/bitnami/suitecrm/conf/cron /etc/cron.d/suitecrm


if [[ "$1" == "nami" && "$2" == "start" ]] ||  [[ "$1" == "/init.sh" ]]; then
   for module in apache php suitecrm; do
    initialize $module
   done
   echo "Starting application ..."
fi

exec /entrypoint.sh "$@"
