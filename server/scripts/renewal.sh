#!/bin/bash

service nginx stop
/certbot-auto renew
service nginx start
