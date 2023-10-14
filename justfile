default:
    just --list

# ======================
# Python Code
# ======================

# lint python project code
lint:
    flake8 ros_ws/src

isort:
    isort ros_ws/src

black:
    black ros_ws/src

fix: isort black lint

# ======================
# Docker
# ======================

docker-build:
    docker build -t project-name .

docker-rm-image:
    docker image rm -f project-name

docker-halt:
    docker stop project-name

docker-rebuild: docker-rm-image docker-build

# docker ros2 core
docker-ros:
    docker ps | grep project-name >/dev/null || \
    docker run \
        -it --rm \
        --name project-name \
        --mount type=bind,source=$(realpath .)/ros_ws,target=/ros_ws \
        --mount type=bind,source=$(realpath .)/.code-server,target=/code-server \
        --mount type=bind,source=$(realpath .)/envs/.bashrc,target=/root/.bashrc \
        project-name \
        bash

# docker bash shell into core ros2 server (if the core is not running, this will be the core)
docker-bash: docker-ros
    docker exec -it project-name /bin/bash 

# docker vs code environment
docker-vs-code: docker-ros
    docker exec -it project-name code tunnel \
        --name project-name --accept-server-license-terms \
        --cli-data-dir /code-server --no-sleep

# ======================
# VM
# ======================

vm-start:
    vagrant up

vm-stop:
    vagrant halt

vm-rebuild:
    vagrant destroy -f
    vagrant up

vm-bash: vm-start
    vagrant ssh

# Run 
vm-vs-code: vm-start
    vagrant ssh -c "code tunnel \
            --name project-name-vm \
            --accept-server-license-terms \
            --no-sleep \
            --cli-data-dir /home/vagrant/.code_server"