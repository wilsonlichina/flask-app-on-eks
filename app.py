from flask import Flask
import platform

app = Flask(__name__)

@app.route('/')
def root():
    return 'Hello, World from EKS!'

@app.route('/flask')
def hello_world():
    arch = platform.machine()
    return 'Hello, World from EKS Flask App running on {arch}!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
