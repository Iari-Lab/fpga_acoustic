import matplotlib.pyplot as plt

import numpy as np
from scipy.io.wavfile import write
import numpy as np
from matplotlib.lines import Line2D
from matplotlib.animation import FuncAnimation
from multiprocessing.managers import BaseManager

class QueueManager(BaseManager):
    pass

QueueManager.register('get_queue')

def normalize_to_01(data, min_val, max_val):
    """
    """
    data = np.asarray(data, dtype=float)  # Ensure array and float type
    # min_val = 536856167
    # min_val = np.min(data)
    # max_val = np.max(data)
    range_val = max_val - min_val
    if range_val == 0:
        return np.zeros_like(data)
    return (data - min_val) / range_val

def update_chart(frame, lines, ax, data_queue, samples, maxs, mins, out_samples):
    if not data_queue.empty(): 
        new_data = data_queue.get()
        mics, sample = new_data
        # print(mics)
        # mics = normalize_to_01(samples[0])
        print(mics,sample)
        if sample==-1:
            for i in range(len(lines)):
                samples[i].clear()
        # Update samples
        for i in range(len(lines)):
            samples[i].extend(mics)
        # samples[i].append(mics)
        print(len(samples[0]))
        if len(samples[0]) >= out_samples:
            data = np.asarray(samples[0], dtype=float)
            # x = np.arange(len(samples[0]))
            # data = np.column_stack([x, samples[0]])
            print("Saving data to data.npy", data)
            np.save('data1.npy', data)
            gen_audio(data)
            samples[0].clear()
            return lines[0],
        # Truncate samples?
        # mples = [s[-1000:] for s in samples]
        # Update each line with the full sample data
        for i in range(len(lines)):
            lines[i].set_data(range(len(samples[i])), samples[i])
        maxs[0] = max(maxs[0],max(samples[0]))
        mins[0] = min(mins[0],min(samples[0]))
        # print(mins[0], maxs[0])
        ax.set_ylim(mins[0] - (mins[0]*1e-3) , maxs[0] + (maxs[0]*1e-3) )
        # print(avg, avg2, avg2-avg)
            # maxs[i] = max(maxs[0],max(samples[i]))
            # mins[i] = min(mins[0],min(samples[i]))
        # assert len(mics) == 1

    # return lines[0], lines[1], lines[2], lines[3], lines[4], lines[5], lines[6], lines[7],
    return lines[0],


def gen_audio(data):
    # 1. Remove DC offset
    data_centered = data - np.mean(data)

    # 2. Normalize the data to the range [-1, 1]
    data_normalized = data_centered / np.max(np.abs(data_centered))

    # 3. Scale to 16-bit integer range
    data_int16 = np.int16(data_normalized * 32767)

    # 4. Write to a WAV file
    sample_rate = 48000  # For example, if your decimated audio is 48 kHz
    write("output.wav", sample_rate, data_int16)


def initialize_plot_matrix(rows=1, cols=1, out_samples=2048):
    """Initialize the dynamic plot with subplots for each microphone."""
    # fig, axes = plt.subplots(rows, cols)  #
    fig, ax = plt.subplots()
    # axes = axes.flatten() 

    lines = []
    mic_labels = ['mic1']
    colors = ['green']

    # for ax, label, color in zip(axes, mic_labels, colors):
    line = Line2D([], [], color=colors[0], label=mic_labels[0])
    ax.add_line(line)
    ax.set_xlim(0, out_samples)
    ax.set_xlabel('Time (us)')
    ax.set_ylabel('A')
    ax.set_title(mic_labels[0])
    lines.append(line)
    # ax.set_ylim(0, 1)
    # ax.set_ylim(5.6e8, 5.95e8)

    # ax.set_ylim(5.2e8, 5.95e8)
    # ax.set_ylim(5.0e8, 5.95e8)

    fig.tight_layout()
    return lines, ax, fig


if __name__ == "__main__":
    manager = QueueManager(address=('localhost', 50000), authkey=b'abc')
    manager.connect()
    data_queue = manager.get_queue()

    # Initialize empty lists for each line's data samples
    samples = [[]]
    maxs = [-1]
    mins = [999999999]
    out_samples = 2048
    lines, ax, fig = initialize_plot_matrix(out_samples)

    ani = FuncAnimation(fig, update_chart, fargs=(lines, ax, data_queue, samples, maxs, mins, out_samples), interval=10)
    plt.show()
