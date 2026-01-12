#!/usr/bin/env bash

#./run_pyenv_app.sh 3.11.9 facedetect.py requirements.txt env_FD_3_12_3 \
 # --image img.jpeg \
 # --cascade haarcascade_frontalface_default.xml \
 # --out out.jpg \
 # --scale 1.2 \
 # --neighbors 5


set -e

PY_VERSION="$1"   # python version
PY_FILE="$2"      # python file
REQ_FILE="$3"     # requirements file
ENV_NAME="$4"     # env folder name

if [[ -z "$4" ]]; then
  echo "Usage: ./run_pyenv_app.sh <py-ver> <py-file> <req.txt> <env> [python_args...]"
  exit 1
fi

# get python args from sh args
# if version is not installed , install ne version
shift 4            # ⭐ remove first 4 args
PY_ARGS="$@"       # ⭐ remaining args go to Python

# Check if python version exists in pyenv
if ! pyenv versions --bare | grep -q "^${PY_VERSION}$"; then
  echo "Installing Python $PY_VERSION ..."
  pyenv install "$PY_VERSION"
fi

# activate with specific version
PY_EXEC="$(pyenv prefix "$PY_VERSION")/bin/python"
if [[ ! -d "$ENV_NAME" ]]; then
  echo "Creating venv: $ENV_NAME ..."
  "$PY_EXEC" -m venv "$ENV_NAME"
fi

# Activate venv
source "$ENV_NAME/bin/activate"

# Install dependencies
#pip install --upgrade pip
pip install -r "$REQ_FILE"

# Run script WITH forwarded params
python "$PY_FILE" $PY_ARGS

# Deactivate
deactivate

#echo "Done."
