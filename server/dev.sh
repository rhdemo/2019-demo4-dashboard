#!/bin/bash


MINISHIFT_IP=$(minishift ip)

PORT=8083 \
DATAGRID_HOST=0.0.0.0 \
DATAGRID_HOTROD_PORT=11222 \
DATAGRID_CONSOLE_HOST="console-datagrid-demo.${MINISHIFT_IP}.nip.io" \
DATAGRID_CONSOLE_PORT=80 \
DATAGRID_CONSOLE_REST_PORT=8080 \
npm run dev
