import tkinter as tk
from tkinter import filedialog, messagebox
import h5py
import os
from datetime import datetime, timedelta
import numpy as np
try:
    from scipy.io import savemat
except ImportError:
    messagebox.showerror("Missing Library", "Scipy is required. Please install it by running: pip install scipy")

# --- Configuration for Variable Extraction ---
TRACK_VARIABLES = {
    "IncidenceAngle": "SPIncidenceAngle",
    "TimeOfReflection": "IntegrationMidPointTime",
    "SpecularAzimuth": "SPAzimuthARF",
    "TransmitterPosX": "TransmitterPositionX",
    "TransmitterPosY": "TransmitterPositionY",
    "TransmitterPosZ": "TransmitterPositionZ",
    "SpecularPointPosX": "SpecularPointPositionX",
    "SpecularPointPosY": "SpecularPointPositionY",
    "SpecularPointPosZ": "SpecularPointPositionZ",
}

CHANNEL_VARIABLES = {
    "SNR": "Incoherent/DDMSNRAtPeakSingleDDM",
    "ReceiverAntennaGain": "Incoherent/AntennaGainTowardsSpecularPoint",
    "EIRP": "Incoherent/EIRP",
    "NoiseFloor": "Incoherent/MeanNoise",
    "QualityFlag": "Incoherent/QC_pass_flag",
    "CoherencyIndex": "Incoherent/Coherency",
    "NoiseKurtosis": "Incoherent/NoiseKurtosis",
    "NormBistaticRadarCross": "Incoherent/Sigma0",
}

class DataExtractorApp:
    def __init__(self, master):
        self.master = master
        master.title("Data Extractor")

        # --- GUI Elements ---
        tk.Label(master, text="Task name:").grid(row=0, sticky=tk.W, padx=5, pady=2)
        self.task_name_entry = tk.Entry(master, width=50)
        self.task_name_entry.grid(row=0, column=1, padx=5, pady=2)

        tk.Label(master, text="Init date (dd/mm/yyyy):").grid(row=1, sticky=tk.W, padx=5, pady=2)
        self.init_date_entry = tk.Entry(master, width=50)
        self.init_date_entry.grid(row=1, column=1, padx=5, pady=2)

        tk.Label(master, text="End date (dd/mm/yyyy):").grid(row=2, sticky=tk.W, padx=5, pady=2)
        self.end_date_entry = tk.Entry(master, width=50)
        self.end_date_entry.grid(row=2, column=1, padx=5, pady=2)

        tk.Label(master, text="Savespace? (yes/no):").grid(row=3, sticky=tk.W, padx=5, pady=2)
        self.savespace_entry = tk.Entry(master, width=50)
        self.savespace_entry.grid(row=3, column=1, padx=5, pady=2)

        tk.Label(master, text="DDM (yes/no):").grid(row=4, sticky=tk.W, padx=5, pady=2)
        self.ddm_entry = tk.Entry(master, width=50)
        self.ddm_entry.grid(row=4, column=1, padx=5, pady=2)

        tk.Label(master, text="Input base path:").grid(row=5, sticky=tk.W, padx=5, pady=2)
        self.input_path_entry = tk.Entry(master, width=50)
        self.input_path_entry.grid(row=5, column=1, padx=5, pady=2)
        tk.Button(master, text="Browse...", command=self.browse_input).grid(row=5, column=2, padx=5, pady=2)

        tk.Label(master, text="Output base path:").grid(row=6, sticky=tk.W, padx=5, pady=2)
        self.output_path_entry = tk.Entry(master, width=50)
        self.output_path_entry.grid(row=6, column=1, padx=5, pady=2)
        tk.Button(master, text="Browse...", command=self.browse_output).grid(row=6, column=2, padx=5, pady=2)

        tk.Label(master, text="LatMin:").grid(row=7, sticky=tk.W, padx=5, pady=2)
        self.lat_min_entry = tk.Entry(master, width=50)
        self.lat_min_entry.grid(row=7, column=1, padx=5, pady=2)

        tk.Label(master, text="LatMax:").grid(row=8, sticky=tk.W, padx=5, pady=2)
        self.lat_max_entry = tk.Entry(master, width=50)
        self.lat_max_entry.grid(row=8, column=1, padx=5, pady=2)

        tk.Label(master, text="LonMin:").grid(row=9, sticky=tk.W, padx=5, pady=2)
        self.lon_min_entry = tk.Entry(master, width=50)
        self.lon_min_entry.grid(row=9, column=1, padx=5, pady=2)

        tk.Label(master, text="LonMax:").grid(row=10, sticky=tk.W, padx=5, pady=2)
        self.lon_max_entry = tk.Entry(master, width=50)
        self.lon_max_entry.grid(row=10, column=1, padx=5, pady=2)

        self.process_button = tk.Button(master, text="OK", command=self.process_data, width=10)
        self.process_button.grid(row=11, column=1, pady=10, sticky=tk.W, padx=5)

        self.cancel_button = tk.Button(master, text="Cancel", command=master.quit, width=10)
        self.cancel_button.grid(row=11, column=1, pady=10, sticky=tk.E, padx=5)

    def browse_input(self):
        self.input_path_entry.delete(0, tk.END)
        self.input_path_entry.insert(0, filedialog.askdirectory())

    def browse_output(self):
        self.output_path_entry.delete(0, tk.END)
        self.output_path_entry.insert(0, filedialog.askdirectory())

    def process_data(self):
        try:
            init_date = datetime.strptime(self.init_date_entry.get(), "%d/%m/%Y")
            end_date = datetime.strptime(self.end_date_entry.get(), "%d/%m/%Y")
        except ValueError:
            messagebox.showerror("Error", "Invalid date format. Please use dd/mm/yyyy.")
            return

        input_base_path = self.input_path_entry.get()
        output_base_path = self.output_path_entry.get()
        task_name = self.task_name_entry.get() or "extraction_run"

        if not os.path.isdir(input_base_path):
            messagebox.showerror("Error", "Input base path is not a valid directory.")
            return
        os.makedirs(output_base_path, exist_ok=True)

        try:
            lat_min = float(self.lat_min_entry.get() or -90.0)
            lat_max = float(self.lat_max_entry.get() or 90.0)
            lon_min = float(self.lon_min_entry.get() or -180.0)
            lon_max = float(self.lon_max_entry.get() or 180.0)
        except ValueError:
            messagebox.showerror("Error", "Lat/Lon values must be valid numbers.")
            return

        current_date = init_date
        while current_date <= end_date:
            year_month_str = current_date.strftime('%Y-%m')
            day_str = current_date.strftime('%d')
            for hour_block in ["H00", "H06", "H12", "H18"]:
                file_path = os.path.join(
                    input_base_path, year_month_str, day_str, hour_block, "metadata_L1_merged.nc"
                )
                if os.path.exists(file_path):
                    self.extract_from_file(file_path, output_base_path, task_name, lat_min, lat_max, lon_min, lon_max)
                else:
                    print(f"File not found, skipping: {file_path}")
            current_date += timedelta(days=1)
        messagebox.showinfo("Success", "Data processing complete.")

    def extract_from_file(self, file_path, output_base_path, task_name, lat_min, lat_max, lon_min, lon_max):
        print(f"Processing file: {file_path}")
        try:
            with h5py.File(file_path, 'r') as hf:
                
                # --- Pass 1: Discover all possible channel names across ALL tracks ---
                all_channel_names = set()
                track_ids = [key for key in hf.keys() if key.isdigit()]
                for track_id in track_ids:
                    track_group = hf.get(f"/{track_id}")
                    if track_group:
                        for item_name in track_group.keys():
                            if item_name.startswith("Channel"):
                                all_channel_names.add(item_name)
                
                sorted_channels = sorted(list(all_channel_names))
                if not sorted_channels:
                    print(f"Warning: No channels found in {file_path}.")

                # --- Pass 2: Initialize a dictionary of lists for all possible variables ---
                matlab_data = {key: [] for key in TRACK_VARIABLES}
                matlab_data.update({'SpecularPointLat': [], 'SpecularPointLon': [], 'TransmitterRange': []})
                for ch in sorted_channels:
                    matlab_data[f"{ch}_PRN"] = []
                    matlab_data[f"{ch}_SVN"] = []
                    for key in CHANNEL_VARIABLES:
                        matlab_data[f"{ch}_{key}"] = []

                # --- Pass 3: Iterate through tracks and points, populating the lists ---
                for track_id in track_ids:
                    lat_path = f"/{track_id}/SpecularPointLat"
                    lon_path = f"/{track_id}/SpecularPointLon"
                    if lat_path not in hf or lon_path not in hf: continue

                    track_lat = hf[lat_path][()]
                    track_lon = hf[lon_path][()]
                    
                    in_bounds = (track_lat >= lat_min) & (track_lat <= lat_max) & \
                                (track_lon >= lon_min) & (track_lon <= lon_max)
                    valid_indices = np.where(in_bounds)[0]

                    if len(valid_indices) == 0: continue

                    # Pre-load all data for the current track to be efficient
                    track_data_cache = {var: hf[f"/{track_id}/{path}"][:] for var, path in TRACK_VARIABLES.items() if f"/{track_id}/{path}" in hf}
                    
                    channel_data_cache = {}
                    track_group = hf[f"/{track_id}"]
                    for ch_name in track_group.keys():
                        if ch_name.startswith("Channel"):
                            channel_group = track_group[ch_name]
                            # CORRECTLY read attributes
                            channel_data_cache[ch_name] = {'PRN': channel_group.attrs.get('PRN', np.nan), 'SVN': channel_group.attrs.get('SVN', np.nan)}
                            for var, path in CHANNEL_VARIABLES.items():
                                channel_data_cache[ch_name][var] = channel_group[path][:] if path in channel_group else None

                    # Iterate through each valid specular point
                    for idx in valid_indices:
                        matlab_data['SpecularPointLat'].append(track_lat[idx])
                        matlab_data['SpecularPointLon'].append(track_lon[idx])

                        for var_name in TRACK_VARIABLES:
                            matlab_data[var_name].append(track_data_cache.get(var_name, [np.nan]*len(track_lat))[idx])

                        sp_x, sp_y, sp_z = matlab_data['SpecularPointPosX'][-1], matlab_data['SpecularPointPosY'][-1], matlab_data['SpecularPointPosZ'][-1]
                        tx_x, tx_y, tx_z = matlab_data['TransmitterPosX'][-1], matlab_data['TransmitterPosY'][-1], matlab_data['TransmitterPosZ'][-1]
                        tx_range = np.sqrt((tx_x - sp_x)**2 + (tx_y - sp_y)**2 + (tx_z - sp_z)**2) if not np.isnan([sp_x, tx_x]).any() else np.nan
                        matlab_data['TransmitterRange'].append(tx_range)

                        # Append data for ALL possible channels, filling with NaN if a channel is missing for this track
                        for ch_name in sorted_channels:
                            if ch_name in channel_data_cache:
                                matlab_data[f"{ch_name}_PRN"].append(channel_data_cache[ch_name]['PRN'])
                                matlab_data[f"{ch_name}_SVN"].append(channel_data_cache[ch_name]['SVN'])
                                for var_name in CHANNEL_VARIABLES:
                                    data_array = channel_data_cache[ch_name].get(var_name)
                                    matlab_data[f"{ch_name}_{var_name}"].append(data_array[idx] if data_array is not None and len(data_array) > idx else np.nan)
                            else: # If this track doesn't have this channel, fill with NaN
                                matlab_data[f"{ch_name}_PRN"].append(np.nan)
                                matlab_data[f"{ch_name}_SVN"].append(np.nan)
                                for var_name in CHANNEL_VARIABLES:
                                    matlab_data[f"{ch_name}_{var_name}"].append(np.nan)

                if not matlab_data['SpecularPointLat']:
                    print(f"No data found within specified bounds for {file_path}. No file generated.")
                    return
                
                # Replace all NaN values with 0 before converting to numpy arrays
                for key, value in matlab_data.items():
                    # Replace different types of NaN values that might exist
                    matlab_data[key] = [0 if isinstance(x, float) and (np.isnan(x) or x in [float('nan'), float('NaN'), float('NAN')]) else x for x in value]
                
                # Convert all lists to numpy arrays for saving
                for key, value in matlab_data.items():
                    matlab_data[key] = np.array(value)

                output_filename = os.path.join(output_base_path, f"{task_name}_{os.path.basename(os.path.dirname(file_path))}.mat")
                savemat(output_filename, matlab_data, do_compression=True)
                print(f"Successfully extracted {len(matlab_data['SpecularPointLat'])} data points to {output_filename}")

        except Exception as e:
            messagebox.showerror("Error", f"Failed to process {file_path}:\n{e}")

if __name__ == "__main__":
    root = tk.Tk()
    app = DataExtractorApp(root)
    root.mainloop()