# Gunicorn configuration file
# https://docs.gunicorn.org/en/stable/configure.html#configuration-file
# https://docs.gunicorn.org/en/stable/settings.html
import multiprocessing

log_file = "-"

accesslog = "-"

workers = multiprocessing.cpu_count() + 1

threads = 2 * multiprocessing.cpu_count()

bind = '0.0.0.0:8000'

wsgi_app = 'core.wsgi:application'

timeout = 1200

keepalive = 1200
