preload_app      true
timeout          5 * 60            # 5 min
worker_processes 5

Rainbows! do
  use :ThreadSpawn
  client_max_body_size 2 ** 20 * 5 # 5MB
end