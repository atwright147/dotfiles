function start_docker -d "Start Docker daemon and wait for it to be ready"
  sudo service docker start
  
  # Wait for Docker daemon to start
  while not docker info >/dev/null 2>&1
    echo "Waiting for Docker daemon to start..."
    sleep 1
  end
  
  echo "Docker daemon started."
  return 0
end
