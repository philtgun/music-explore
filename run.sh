#!/usr/bin/env bash
set -e

echo "IMPORTANT: make sure that you:"
echo "- have copied config-example.py to instance/config.py"
echo "- set the variables ROOT_DIR and AUDIO_DIR as absolute paths"
echo "- created the soft symlink app/static/audio pointing to your audio"

echo 'Setting up Python environment...'
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
pip install essentia-tensorflow tinytag

echo 'Downloading models...'
mkdir -p essentia-tf-models
cd essentia-tf-models
wget https://essentia.upf.edu/models/autotagging/msd/msd-musicnn-1.pb -O msd-musicnn.pb --no-check-certificate
wget https://essentia.upf.edu/models/autotagging/msd/msd-vgg-1.pb -O msd-vgg.pb --no-check-certificate
wget https://essentia.upf.edu/models/autotagging/mtt/mtt-musicnn-1.pb -O mtt-musicnn.pb --no-check-certificate
wget https://essentia.upf.edu/models/autotagging/mtt/mtt-vgg-1.pb -O mtt-vgg.pb --no-check-certificate
wget https://essentia.upf.edu/models/feature-extractors/vggish/audioset-vggish-3.pb -O audioset-vggish.pb --no-check-certificate
cd ..

echo 'Processing the music collection'
flask init-db
flask index-all-audio
flask extract-all essentia-tf-models
flask reduce-all
flask index-all-embeddings
flask aggregate-all
flask load-id3-metadata

echo "Done! You can run the app now with 'source venv/bin/activate; flask run'"
