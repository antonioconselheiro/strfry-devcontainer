#!/bin/bash
exec >> /log/log.log 2>&1
nginx -g 'daemon off;' &
strfry relay;