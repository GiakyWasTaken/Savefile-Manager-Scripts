#!/bin/bash

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide an HTTP status code as an argument"
    exit 1
fi

# Check if the provided argument is a number
if ! [[ $1 =~ ^[0-9]+$ ]]; then
    echo "HTTP status code must be a number"
    exit 1
fi

# Define an associative array with HTTP status codes and their meanings
declare -A http_codes=(
    [100]="Continue"
    [101]="Switching Protocols"
    [200]="OK"
    [201]="Created"
    [204]="No Content"
    [202]="Accepted"
    [203]="Non-Authoritative Information"
    [205]="Reset Content"
    [206]="Partial Content"
    [207]="Multi-Status"
    [208]="Already Reported"
    [226]="IM Used"
    [300]="Multiple Choices"
    [301]="Moved Permanently"
    [302]="Found"
    [303]="See Other"
    [304]="Not Modified"
    [307]="Temporary Redirect"
    [308]="Permanent Redirect"
    [400]="Bad Request"
    [401]="Unauthorized"
    [403]="Forbidden"
    [404]="Not Found"
    [405]="Method Not Allowed"
    [406]="Not Acceptable"
    [407]="Proxy Authentication Required"
    [408]="Request Timeout"
    [409]="Conflict"
    [410]="Gone"
    [411]="Length Required"
    [412]="Precondition Failed"
    [413]="Payload Too Large"
    [414]="URI Too Long"
    [415]="Unsupported Media Type"
    [416]="Range Not Satisfiable"
    [417]="Expectation Failed"
    [418]="I'm a teapot"
    [421]="Misdirected Request"
    [422]="Unprocessable Entity"
    [423]="Locked"
    [424]="Failed Dependency"
    [425]="Too Early"
    [426]="Upgrade Required"
    [428]="Precondition Required"
    [429]="Too Many Requests"
    [431]="Request Header Fields Too Large"
    [451]="Unavailable For Legal Reasons"
    [500]="Internal Server Error"
    [501]="Not Implemented"
    [502]="Bad Gateway"
    [503]="Service Unavailable"
    [504]="Gateway Timeout"
    [505]="HTTP Version Not Supported"
    [506]="Variant Also Negotiates"
    [507]="Insufficient Storage"
    [508]="Loop Detected"
    [510]="Not Extended"
    [511]="Network Authentication Required"
)

# Get the provided HTTP status code
status_code=$1

# Check if the provided status code exists in the array
if [ ${http_codes[$status_code]+_} ]; then
    echo "HTTP status code $status_code: ${http_codes[$status_code]}"
else
    echo "Unknown HTTP status code: $status_code"
fi