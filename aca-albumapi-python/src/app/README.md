fastapi dev app/test_api.py
fastapi dev app/main.py

curl -X 'GET' \
  'http://127.0.0.1:8000/albums' \
  -H 'accept: application/json'