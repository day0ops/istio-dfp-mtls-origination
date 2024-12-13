#!/usr/bin/env bash

SCRIPT_NAME="`basename $0`"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## ----------- main cmd func
apply() {
    ## deploy curl client
    kubectl apply -f $DIR/apps/curl/ns.yaml
    kubectl apply -n curl -f $DIR/apps/curl/deploy.yaml

    ## enable cluster-wide mTLS with peer auth (optional)
    kubectl apply -f $DIR/config/peerauth.yaml

    ## only allow aspnet4you.com
    kubectl apply -f $DIR/config/aspnet4you-se.yaml

    ## configure Egress GW, VS and DR
    kubectl apply -f $DIR/config/egress-dr.yaml
    kubectl apply -f $DIR/config/egress-gw.yaml
    kubectl apply -f $DIR/config/egress-vs.yaml
    kubectl apply -f $DIR/config/envoyfilter.yaml
}

delete() {
    kubectl delete -f $DIR/config/peerauth.yaml
    kubectl delete -f $DIR/config/aspnet4you-se.yaml
    kubectl delete -f $DIR/config/egress-dr.yaml
    kubectl delete -f $DIR/config/egress-gw.yaml
    kubectl delete -f $DIR/config/egress-vs.yaml
    kubectl delete -f $DIR/config/envoyfilter.yaml

    kubectl delete -f $DIR/apps/curl/ns.yaml
}

## ----------- helpers
cmdline_arg_processor_help() {
    local caller=$1
    cat <<EOF
usage: $caller

-a  | --apply       Apply the artifacts
-d  | --delete      Clean the artifacts
-h  | --help        Usage
EOF

    exit 1
}

cmdline_arg_processor() {
    local source_name=$1; shift
    local apply_func=$1; shift
    local delete_func=$1; shift

    local short=a,d,h
    local long=apply,delete,help
    local opts=$(getopt -a -n "setup.sh" --options $short --longoptions $long -- "$@")

    eval set -- "$opts"

    local opt=$1; shift

    if [[ $opt == "" ]]; then
        echo "Unrecognized option provided, check help below"
        cmdline_arg_processor_help $source_name
    fi

    while :; do
        case "$opt" in
        -a | --apply)
            $apply_func
            break
            ;;
        -d | --delete)
            $delete_func
            break
            ;;
        -h | --help)
            cmdline_arg_processor_help $source_name
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unexpected option: $opt"
            cmdline_arg_processor_help $source_name
            ;;
        esac
    done
}

cmdline_arg_processor $SCRIPT_NAME apply delete $1