from multiprocessing.managers import BaseManager
from multiprocessing import Queue

queue = Queue()

class QueueManager(BaseManager):
    pass

QueueManager.register('get_queue', callable=lambda: queue)

def start_manager():
    manager = QueueManager(address=('', 50000), authkey=b'abc')
    server = manager.get_server()
    print("Manager server started. Waiting for connections...")
    server.serve_forever()

if __name__ == "__main__":
    start_manager()




