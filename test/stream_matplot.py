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
            max_y = max(map(max, samples))
            min_y = min(map(min, samples))
            ax[i].set_ylim(min_y * 1.1, max_y * 1.1)

    return lines[0], lines[1], lines[2], lines[3], lines[4], lines[5], lines[6], lines[7],

def initialize_plot_matrix(rows=2, cols=4):
    """Initialize the dynamic plot with subplots for each microphone."""
    fig, axes = plt.subplots(rows, cols, figsize=(12, 8))  #
    axes = axes.flatten() 

    lines = []
    mic_labels = ['mic1', 'mic2', 'mic3', 'mic4', 'mic5', 'mic6', 'mic7', 'mic8']
    colors = ['green', 'black', 'red', 'blue', 'orange', 'magenta', 'pink', 'brown']

    for ax, label, color in zip(axes, mic_labels, colors):
        line = Line2D([], [], color=color, label=label)
        ax.add_line(line)
        ax.set_xlim(0, 1000)
        ax.set_xlabel('Time (us)')
        ax.set_ylabel('A')
        ax.set_title(label)
        lines.append(line)

    fig.tight_layout()
    return lines, axes, fig


if __name__ == "__main__":
    manager = QueueManager(address=('localhost', 50000), authkey=b'abc')
    manager.connect()
    data_queue = manager.get_queue()

    # Initialize empty lists for each line's data samples
    samples = [[], [], [], [], [], [], [], []]
    lines, ax, fig = initialize_plot_matrix()

    ani = FuncAnimation(fig, update_chart, fargs=(lines, ax, data_queue, samples), interval=100)
    plt.show()
