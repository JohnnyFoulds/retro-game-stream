import subprocess
import time
import sys
import os
import glob
import random
import argparse
import threading
import queue
import signal

# OS-Specific imports for "Raw Mode" instant keystrokes
try:
    import msvcrt
    WINDOWS = True
except ImportError:
    import tty
    import termios
    WINDOWS = False

# --- CLI ARGUMENT PARSER FOR THE DJ ---
parser = argparse.ArgumentParser(description="🎧 CA Stream Radio DJ")
parser.add_argument('-g', '--genre', type=str, default=None,
    choices=['chiptune', 'chillstep', 'dubstep', 'piano', 'lofi', 
             'synthwave', 'ambient', 'acid'], help="Lock to a specific genre")
parser.add_argument('-m', '--mood', type=str, default=None,
    choices=['epic', 'happy', 'spooky', 'cyberpunk', 'chill', 'lofi', 
             'synthwave', 'ambient'], help="Lock to a specific chord mood")
parser.add_argument('--melody', type=str, default=None,
    choices=['ca', 'motif'], help="Lock the melody generation style")
parser.add_argument('--dj_rule', type=int, default=110, 
    help="The CA Rule powering the DJ's brain (Default: 110)")
args = parser.parse_args()

# The DNA of our Radio Station 
GENRES = ['chiptune', 'chillstep', 'dubstep', 'piano', 'lofi', 
          'synthwave', 'ambient', 'acid']
MOODS = ['epic', 'happy', 'spooky', 'cyberpunk', 'chill', 'lofi', 
         'synthwave', 'ambient']
MELODIES = ['ca', 'motif']

# Target BPM ranges for humanization
BPM_RANGES = {
    'chiptune': (120, 160), 'chillstep': (130, 145), 
    'dubstep': (135, 150), 'piano': (80, 120),
    'lofi': (70, 85), 'synthwave': (95, 125),
    'ambient': (30, 50), 'acid': (128, 142)
}

WORDS = ["neon", "rain", "cyber", "hacker", "coffee", "space", 
         "matrix", "pizza", "midnight", "dungeon", "synth", "ghost"]

WIDTH = 16  # 16 bits of playlist memory
input_queue = queue.Queue()

# --- KEYBOARD INPUT LISTENER (RAW MODE) ---
def command_listener():
    """Captures instant keystrokes without waiting for Enter."""
    while True:
        try:
            if WINDOWS:
                ch_bytes = msvcrt.getch()
                if ch_bytes == b'\x03': # Ctrl+C
                    os.kill(os.getpid(), signal.SIGINT)
                ch = ch_bytes.decode('utf-8').lower()
            else:
                fd = sys.stdin.fileno()
                old_settings = termios.tcgetattr(fd)
                try:
                    tty.setraw(sys.stdin.fileno())
                    ch = sys.stdin.read(1)
                finally:
                    termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
                
                if ch == '\x03': # Ctrl+C trap
                    os.kill(os.getpid(), signal.SIGINT)
                ch = ch.lower()

            if ch == 'n':
                input_queue.put('skip')
            elif ch == 'p':
                input_queue.put('prev')
        except Exception:
            pass

# --- CELLULAR AUTOMATA DJ LOGIC ---
def get_next_state(state, rule):
    next_state = [0] * len(state)
    for i in range(len(state)):
        left = state[i-1] if i > 0 else state[-1]
        center = state[i]
        right = state[i+1] if i < len(state)-1 else state[0]
        idx = (left << 2) | (center << 1) | right
        next_state[i] = (rule >> idx) & 1
    return next_state

def get_latest_synth_script():
    files = glob.glob("ca_synth*.py")
    if not files: return None
    return max(files, key=os.path.getmtime)

def main():
    # \r snaps the cursor to the far left wall, cleaning up the start
    print("\r\n" + "=" * 70)
    print(f" 🤖 Turing-Complete DJ (Rule {args.dj_rule}) 🤖".center(70))
    print("=" * 70 + "\n")
    
    # Start the instant-keystroke listener thread
    listener_thread = threading.Thread(target=command_listener, daemon=True)
    listener_thread.start()
    
    current_proc = None
    random.seed() 
    state = [random.randint(0, 1) for _ in range(WIDTH)]
    if sum(state) == 0: state[WIDTH // 2] = 1 
    
    history = []
    current_track_idx = -1
    action = 'next'
    
    try:
        while True:
            synth_script = get_latest_synth_script()
            if not synth_script:
                print("\r\n[DJ] ❌ No 'ca_synth*.py' found! Retrying in 5s...")
                time.sleep(5)
                continue

            # --- 1. DETERMINE TRACK DATA ---
            if action == 'prev':
                current_track_idx = max(0, current_track_idx - 1)
            else:
                current_track_idx += 1

            if current_track_idx < len(history):
                state, track_bpm, seed, play_time = history[current_track_idx]
            else:
                state = get_next_state(state, args.dj_rule)
                g_idx = (state[0] << 2) | (state[1] << 1) | state[2]
                next_genre = args.genre if args.genre else GENRES[g_idx]
                
                min_bpm, max_bpm = BPM_RANGES[next_genre]
                track_bpm = random.randint(min_bpm, max_bpm)
                
                t_idx = (state[7] << 2) | (state[8] << 1) | state[9]
                play_time = 120 + (t_idx * 15) 
                
                seed_bits = "".join([str(b) for b in state[10:]])
                seed = f"{random.choice(WORDS)}_{seed_bits}"
                
                history.append((state.copy(), track_bpm, seed, play_time))
            
            m_idx = (state[3] << 2) | (state[4] << 1) | state[5]
            mel_idx = state[6]
            g_idx = (state[0] << 2) | (state[1] << 1) | state[2]
            
            next_genre = args.genre if args.genre else GENRES[g_idx]
            next_mood = args.mood if args.mood else MOODS[m_idx]
            next_melody = args.melody if args.melody else MELODIES[mel_idx]
            
            if next_genre == 'ambient': next_melody = 'ca'
            if next_genre == 'lofi' and next_mood == 'epic': next_mood = 'lofi'
            
            # --- 2. BUILD THE COMMAND ---
            cmd = [
                "python", synth_script, 
                "--genre", next_genre, 
                "--mood", next_mood, 
                "--melody", next_melody,
                "--bpm", str(track_bpm), 
                "--seed", seed, 
                "--fade_in", "4"
            ]
            
            # \r\n\n guarantees we skip past the synth visuals gracefully!
            print(f"\r\n\n" + "=" * 70)
            print(f"[DJ] 🎛️ CROSSFADING TO TRACK #{current_track_idx + 1}")
            print(f"[DJ] 🧬 State: {''.join(['█' if s else ' ' for s in state])}")
            print(f"[DJ] ⏱️ Duration: {play_time} sec | 🎚️ BPM: {track_bpm}")
            print(f"[DJ] 🎶 Command: {' '.join(cmd)}")
            print(f"[DJ] ⌨️  Press 'n' (Next) or 'p' (Prev) at any time!")
            print("=" * 70 + "\n")
            
            # Use DEVNULL to prevent the synth from stealing terminal focus
            next_proc = subprocess.Popen(cmd, stdin=subprocess.DEVNULL)
            
            if current_proc is not None:
                flag_file = f"fade_{current_proc.pid}.flag"
                with open(flag_file, 'w') as f: f.write("fade")
                    
            current_proc = next_proc
            
            # --- 3. WAIT FOR DURATION OR KEYBOARD INPUT ---
            start_time = time.time()
            action = 'next' 
            
            while time.time() - start_time < play_time:
                try:
                    user_cmd = input_queue.get(timeout=0.5)
                    if user_cmd in ['skip', 'prev']:
                        action = user_cmd
                        print(f"\r\n\n[DJ] ⏭️ User triggered '{action.upper()}'!")
                        break 
                except queue.Empty:
                    pass
            
    except KeyboardInterrupt:
        print("\r\n\n[DJ] Shutting down the radio...")
        if current_proc:
            flag_file = f"fade_{current_proc.pid}.flag"
            with open(flag_file, 'w') as f: f.write("fade")
            time.sleep(3) 
            current_proc.terminate()
            
        for f in os.listdir():
            if f.startswith("fade_") and f.endswith(".flag"):
                os.remove(f)
        sys.exit(0)

if __name__ == "__main__":
    main()
