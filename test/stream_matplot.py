import matplotlib.pyplot as plt
import numpy as np
from matplotlib.lines import Line2D
from matplotlib.animation import FuncAnimation
from multiprocessing.managers import BaseManager

class QueueManager(BaseManager):
    pass

QueueManager.register('get_queue')


def update_chart(frame, lines, ax, data_queue, samples):
    if not data_queue.empty(): 
        new_data = data_queue.get()
        print("new_data: ", new_data)
        mics, sample = new_data
        if sample==-1:
            for i in range(8):
                samples[i].clear()
        # Update samples
        for i in range(8):
            samples[i].append(mics[i])
        # Truncate samples?
        # mples = [s[-1000:] for s in samples]
        # Update each line with the full sample data
        for i in range(8):
            lines[i].set_data(range(len(samples[i])), samples[i])
        # y-axis limits 
        max_y = max(map(max, samples))
        min_y = min(map(min, samples))
        ax.set_ylim(min_y * 1.1, max_y * 1.1)

    return lines[0], lines[1], lines[2], lines[3], lines[4], lines[5], lines[6], lines[7],

def initialize_plot():
    """Initialize the dynamic plot."""
    fig, ax = plt.subplots()
    line1 = Line2D([], [], color='green', label='mic1')
    ax.add_line(line1)
    line2 = Line2D([], [], color='black', label='mic2')
    ax.add_line(line2)
    line3 = Line2D([], [], color='red', label='mic3')
    ax.add_line(line3)
    line4 = Line2D([], [], color='blue', label='mic4')
    ax.add_line(line4)
    line5 = Line2D([], [], color='orange', label='mic5')
    ax.add_line(line5)
    line6 = Line2D([], [], color='magenta', label='mic6')
    ax.add_line(line6)
    line7 = Line2D([], [], color='pink', label='mic7')
    ax.add_line(line7)
    line8 = Line2D([], [], color='brown', label='mic8')
    ax.add_line(line8)
    ax.set_xlabel('Time (us)')
    ax.set_ylabel('sesenta')
    ax.legend()
    return [line1,line2,line3,line4,line5,line6,line7,line8], ax, fig


if __name__ == "__main__":
    manager = QueueManager(address=('localhost', 50000), authkey=b'abc')
    manager.connect()
    data_queue = manager.get_queue()

    # Initialize empty lists for each line's data samples
    samples = [[], [], [], [], [], [], [], []]
    lines, ax, fig = initialize_plot()

    ani = FuncAnimation(fig, update_chart, fargs=(lines, ax, data_queue, samples), interval=100)
    plt.show()
