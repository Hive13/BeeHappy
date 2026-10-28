import multiprocessing

workers = multiprocessing.cpu_count() * 2 + 1

wsgi_app = 'bhapi:create_app()'

bind = '0.0.0.0:5001'

umask = 0o007