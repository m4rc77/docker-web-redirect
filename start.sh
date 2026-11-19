#!/bin/bash
if [ -z "$REDIRECT_TARGET" ]; then
	echo "Redirect target variable not set (REDIRECT_TARGET)"
	exit 1
else
	# Add https if not set
	if ! [[ $REDIRECT_TARGET =~ ^https?:// ]]; then
		REDIRECT_TARGET="https://$REDIRECT_TARGET"
	fi

	# Add trailing slash
	if [[ "${REDIRECT_TARGET: -1}" != "/" ]]; then
		REDIRECT_TARGET="$REDIRECT_TARGET/"
	fi
fi

# Default to 8080
LISTEN="8080"
# Listen to PORT variable given on Cloud Run Context
if [ -n "$PORT" ]; then
	if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
		echo "Invalid PORT specified: $PORT (must be a number between 1 and 65535)"
		exit 1
	fi
	LISTEN="$PORT"
fi

# Validate REDIRECT_TARGET to prevent configuration injection
# Disallow whitespace, quotes, semicolons, curly braces, and control characters
if [[ "$REDIRECT_TARGET" =~ [[:cntrl:][:space:]\'\"\;\{\}] ]]; then
	echo "Invalid characters detected in REDIRECT_TARGET"
	exit 1
fi

cat <<EOF > /etc/nginx/conf.d/default.conf
server {
	listen ${LISTEN};

	rewrite ^/(.*)\$ ${REDIRECT_TARGET}\$1 permanent;
}
EOF


echo "Listening to $LISTEN, Redirecting HTTP requests to ${REDIRECT_TARGET}..."

exec nginx -g "daemon off;"
