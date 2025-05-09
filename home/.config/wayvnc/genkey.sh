#!/usr/bin/env bash

openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -sha384 \
	-days 3650 -nodes -keyout tls_key.pem -out tls_cert.pem \
	-subj /CN=localhost \
	-addext subjectAltName=DNS:localhost,DNS:localhost,IP:0.0.0.0
