ARG PMA_VERSION

FROM phpmyadmin/phpmyadmin:$PMA_VERSION

COPY --from=builder env/phpmyadmin/config.user.inc.php /etc/phpmyadmin/config.user.inc.php
